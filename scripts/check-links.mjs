#!/usr/bin/env node

/**
 * Validates internal Markdown links and anchors across documentation files in OmenArchive.
 */

import fs from "fs";
import path from "path";
import { fileURLToPath } from "url";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const archiveRoot = path.resolve(__dirname, "..");

function findMarkdownFiles(dir) {
  let results = [];
  if (!fs.existsSync(dir)) return results;
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      if (entry.name !== "node_modules" && entry.name !== ".git") {
        results = results.concat(findMarkdownFiles(full));
      }
    } else if (entry.name.endsWith(".md")) {
      results.push(full);
    }
  }
  return results;
}

const rootFiles = ["README.md", "CONTRIBUTING.md", "USAGE.md"]
  .map((f) => path.join(archiveRoot, f))
  .filter((f) => fs.existsSync(f));

const docsFiles = findMarkdownFiles(path.join(archiveRoot, "docs"));
const allMdFiles = rootFiles.concat(docsFiles);

function slugify(text) {
  return text
    .toLowerCase()
    .replace(/[^\w\s-]/g, "")
    .trim()
    .replace(/\s+/g, "-");
}

function extractHeadings(content) {
  const headings = new Set();
  const lines = content.split("\n");
  for (const line of lines) {
    const match = line.match(/^#{1,6}\s+(.+)$/);
    if (match) {
      headings.add(slugify(match[1]));
    }
  }
  return headings;
}

const fileHeadings = new Map();
for (const file of allMdFiles) {
  try {
    const content = fs.readFileSync(file, "utf8");
    fileHeadings.set(file, extractHeadings(content));
  } catch (e) {}
}

const linkRegex = /\[([^\]]+)\]\(([^)]+)\)/g;
let errors = 0;
let linksChecked = 0;

for (const file of allMdFiles) {
  const content = fs.readFileSync(file, "utf8");
  const relSource = path.relative(archiveRoot, file);
  let match;

  while ((match = linkRegex.exec(content)) !== null) {
    const destination = match[2].trim();
    if (
      destination.startsWith("http://") ||
      destination.startsWith("https://") ||
      destination.startsWith("mailto:") ||
      destination.startsWith("omen://")
    ) {
      continue;
    }

    linksChecked++;
    const [destPath, anchor] = destination.split("#");
    let targetFile = file;

    if (destPath) {
      targetFile = path.resolve(path.dirname(file), destPath);
    }

    if (!fs.existsSync(targetFile)) {
      console.error(
        `${relSource}: broken link destination '${destination}' (file not found: ${path.relative(
          archiveRoot,
          targetFile
        )})`
      );
      errors++;
      continue;
    }

    if (anchor) {
      const headings = fileHeadings.get(targetFile);
      if (headings && !headings.has(anchor.toLowerCase())) {
        console.error(
          `${relSource}: broken anchor '#${anchor}' in '${destination}' (available: ${Array.from(
            headings
          ).join(", ")})`
        );
        errors++;
      }
    }
  }
}

if (errors > 0) {
  console.error(`\nLink check failed: ${errors} error(s) found across ${linksChecked} links.`);
  process.exit(1);
} else {
  console.log(`Link check passed: ${linksChecked} internal link(s) verified across ${allMdFiles.length} file(s).`);
}
