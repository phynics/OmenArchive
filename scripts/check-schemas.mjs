#!/usr/bin/env node

/**
 * Validates YAML files in OmenArchive against the JSON schemas declared in schemas/.
 *
 * This standalone schema check runs on hosted runners and local developer machines
 * without requiring a Swift toolchain.
 *
 * What it covers:
 * - Structural YAML syntax and UTF-8 encoding.
 * - Conformance of each record to its family schema (required properties, types, enums,
 *   patterns, ranges, and layout rules).
 * - Publication manifests and collections against their schemas.
 *
 * What it does NOT cover (verified by the full maintainer gate in OmenArchiveKit):
 * - Cross-record reference resolution (@family.slug and omen:// links).
 * - Mechanics effect inputs against compiled effect descriptors.
 * - Derived rule and identity UUID computation and collision checks.
 */

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";
import { createRequire } from "module";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const archiveRoot = path.resolve(__dirname, "..");
const require = createRequire(import.meta.url);

let Ajv2020, addFormats, YAML;
try {
  Ajv2020 = require("ajv/dist/2020.js");
  addFormats = require("ajv-formats");
  YAML = require("yaml");
} catch (err) {
  console.error("Error loading validation dependencies (ajv, ajv-formats, yaml).");
  console.error("Run: npm install --no-save ajv@^8.17.1 ajv-formats@^3.0.1 yaml@^2.7.0");
  process.exit(1);
}

const schemasDir = path.join(archiveRoot, "schemas");
const manifestPath = path.join(schemasDir, "archive-format.json");
if (!fs.existsSync(manifestPath)) {
  console.error(`Archive format manifest not found at ${manifestPath}`);
  process.exit(1);
}

const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));

const ajv = new Ajv2020({ allErrors: true, strict: false });
addFormats(ajv);
ajv.addKeyword("x-omen-ownership");

const schemaMap = new Map();

function addSchemas(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      addSchemas(full);
    } else if (entry.name.endsWith(".json") && entry.name !== "archive-format.json") {
      const content = JSON.parse(fs.readFileSync(full, "utf8"));
      ajv.addSchema(content);
      schemaMap.set(entry.name, content.$id);
    }
  }
}
addSchemas(schemasDir);

function schemaForRelativePath(relPath) {
  const normalized = relPath.replace(/\\/g, "/");
  if (normalized.startsWith("collections/")) {
    return manifest.collections.schema;
  }
  const parts = normalized.split("/");
  if (parts.length === 3 && parts[0] === "src" && parts[2] === "publication.yml") {
    return manifest.publication.schema;
  }
  if (parts.length < 4 || parts[0] !== "src") return null;

  const familyDir = parts[2];
  const family = manifest.families.find((f) => f.directory === familyDir);
  if (!family) return null;

  if (family.layout === "flat") {
    return parts.length === 4 ? family.schema : null;
  }

  // Bundle root: src/{pub}/{family}/{bundle}/{bundle}.yml
  if (parts.length === 5 && parts[4] === `${parts[3]}.yml`) {
    return family.schema;
  }

  // Bundle children: src/{pub}/{family}/{bundle}/{childDir}/{slug}.yml
  if (parts.length === 6) {
    const owner = parts[3];
    const childDir = parts[4];
    if (family.children) {
      const child = family.children.find((c) => c.directory === childDir);
      if (child) return child.schema;
    }
    if (manifest.customGroups) {
      const custom = manifest.customGroups.find(
        (g) =>
          g.familyID === family.id &&
          g.directory === childDir &&
          (!g.ownerPath || g.ownerPath.includes(owner))
      );
      if (custom) return custom.schema;
    }
  }

  return null;
}

function findYamlFiles(dir) {
  let results = [];
  if (!fs.existsSync(dir)) return results;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      results = results.concat(findYamlFiles(full));
    } else if (entry.name.endsWith(".yml") || entry.name.endsWith(".yaml")) {
      results.push(path.relative(archiveRoot, full));
    }
  }
  return results;
}

const args = process.argv.slice(2);
let targetFiles = [];

if (args.length > 0) {
  for (const arg of args) {
    const abs = path.resolve(process.cwd(), arg);
    const resolved = path.relative(archiveRoot, abs);
    targetFiles.push(resolved);
  }
} else {
  targetFiles = findYamlFiles(path.join(archiveRoot, "src")).concat(
    findYamlFiles(path.join(archiveRoot, "collections"))
  );
}

let totalErrors = 0;
const startTime = Date.now();

for (const relPath of targetFiles) {
  const fullPath = path.join(archiveRoot, relPath);
  if (!fs.existsSync(fullPath)) {
    console.error(`${relPath}: file not found`);
    totalErrors++;
    continue;
  }

  const schemaFile = schemaForRelativePath(relPath);
  if (!schemaFile) {
    console.error(
      `${relPath}: unmapped archive path (does not match declared family or collection layout in archive-format.json)`
    );
    totalErrors++;
    continue;
  }

  const schemaId = schemaMap.get(schemaFile);
  if (!schemaId) {
    console.error(`${relPath}: schema not loaded for ${schemaFile}`);
    totalErrors++;
    continue;
  }

  const validate = ajv.getSchema(schemaId);
  if (!validate) {
    console.error(`${relPath}: failed to retrieve compiled schema ${schemaId}`);
    totalErrors++;
    continue;
  }

  let content;
  try {
    content = fs.readFileSync(fullPath, "utf8");
  } catch (err) {
    console.error(`${relPath}: unreadable file: ${err.message}`);
    totalErrors++;
    continue;
  }

  let parsed;
  try {
    parsed = YAML.parse(content);
  } catch (err) {
    console.error(`${relPath}: YAML parse error: ${err.message}`);
    totalErrors++;
    continue;
  }

  const isValid = validate(parsed);
  if (!isValid) {
    for (const error of validate.errors || []) {
      const dataLoc = error.instancePath ? `$${error.instancePath}` : "$";
      console.error(
        `${relPath}: schema error at ${dataLoc}: ${error.message}${
          error.params ? " (" + JSON.stringify(error.params) + ")" : ""
        }`
      );
      totalErrors++;
    }
  }
}

const elapsedSec = ((Date.now() - startTime) / 1000).toFixed(2);

if (totalErrors > 0) {
  console.error(
    `\nSchema validation failed: ${totalErrors} error(s) found across ${targetFiles.length} file(s) in ${elapsedSec}s.`
  );
  console.error(
    "For common schema errors and fixes, see docs/troubleshooting.md."
  );
  process.exit(1);
} else {
  console.log(
    `Schema validation passed: ${targetFiles.length} file(s) checked in ${elapsedSec}s with 0 errors.`
  );
}
