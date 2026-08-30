#!/usr/bin/env ruby
# frozen_string_literal: true

require "json"
require "pathname"

path = Pathname.new(ARGV.fetch(0, File.expand_path("../schemas/utility-types/rules.schema.json", __dir__)))
schema = JSON.parse(path.read)
defs = schema.fetch("$defs")

defs.delete("effectTemplate")
defs.delete("literalValue")

defs["effectReference"] = {
  "type" => "object",
  "properties" => {
    "kindID" => { "type" => "string", "pattern" => "^[a-z0-9.-]+/effect/[a-z0-9-]+$" },
    "revision" => { "type" => "integer", "minimum" => 1 }
  },
  "required" => ["kindID", "revision"],
  "additionalProperties" => false
}

defs["registeredValue"] = {
  "type" => "object",
  "properties" => {
    "typeID" => { "type" => "string", "pattern" => "^[a-z0-9.-]+/value/[a-z0-9-]+$" },
    "revision" => { "type" => "integer", "minimum" => 1 },
    "payload" => {}
  },
  "required" => ["typeID", "revision", "payload"],
  "additionalProperties" => false
}

defs["selectionOptions"] = {
  "oneOf" => [
    {
      "type" => "object",
      "properties" => { "kind" => { "const" => "unrestricted" } },
      "required" => ["kind"],
      "additionalProperties" => false
    },
    {
      "type" => "object",
      "properties" => {
        "kind" => { "const" => "explicit" },
        "values" => { "type" => "array", "minItems" => 1, "items" => { "$ref" => "#/$defs/registeredValue" } }
      },
      "required" => ["kind", "values"],
      "additionalProperties" => false
    },
    {
      "type" => "object",
      "properties" => {
        "kind" => { "const" => "resourceFiltered" },
        "filter" => { "$ref" => "resource-filter.schema.json" }
      },
      "required" => ["kind", "filter"],
      "additionalProperties" => false
    }
  ]
}

defs["selection"] = {
  "type" => "object",
  "properties" => {
    "id" => { "type" => "string", "format" => "uuid" },
    "lookupName" => { "type" => "string", "minLength" => 1 },
    "valueTypeID" => { "type" => "string", "pattern" => "^[a-z0-9.-]+/value/[a-z0-9-]+$" },
    "options" => { "$ref" => "#/$defs/selectionOptions" }
  },
  "required" => ["id", "lookupName", "valueTypeID", "options"],
  "additionalProperties" => false
}

defs["source"] = {
  "type" => "object",
  "oneOf" => [
    {
      "properties" => {
        "kind" => { "const" => "literal" },
        "value" => { "$ref" => "#/$defs/registeredValue" }
      },
      "required" => ["kind", "value"],
      "additionalProperties" => false
    },
    {
      "properties" => {
        "kind" => { "const" => "lookupByID" },
        "id" => { "type" => "string", "minLength" => 1 }
      },
      "required" => ["kind", "id"],
      "additionalProperties" => false
    },
    {
      "properties" => {
        "kind" => { "const" => "lookupByName" },
        "name" => { "type" => "string", "minLength" => 1 }
      },
      "required" => ["kind", "name"],
      "additionalProperties" => false
    },
    {
      "properties" => {
        "kind" => { "const" => "selection" },
        "selection" => { "$ref" => "#/$defs/selection" }
      },
      "required" => ["kind", "selection"],
      "additionalProperties" => false
    }
  ]
}

defs["expectedValue"] = {
  "type" => "object",
  "properties" => {
    "valueTypeID" => { "type" => "string", "pattern" => "^[a-z0-9.-]+/value/[a-z0-9-]+$" },
    "source" => { "$ref" => "#/$defs/source" }
  },
  "required" => ["valueTypeID", "source"],
  "additionalProperties" => false
}

defs["inputRecipe"] = {
  "type" => "object",
  "properties" => {
    "inputName" => { "type" => "string", "minLength" => 1 },
    "expectedValue" => { "$ref" => "#/$defs/expectedValue" }
  },
  "required" => ["inputName", "expectedValue"],
  "additionalProperties" => false
}

defs["rule"] = {
  "type" => "object",
  "properties" => {
    "id" => { "type" => "string", "format" => "uuid" },
    "effectReference" => { "$ref" => "#/$defs/effectReference" },
    "inputRecipes" => { "type" => "array", "items" => { "$ref" => "#/$defs/inputRecipe" }, "default" => [] },
    "startLevel" => { "type" => "integer", "minimum" => 1, "maximum" => 20 },
    "prerequisites" => { "type" => "array", "items" => { "$ref" => "#/$defs/prerequisite" }, "default" => [] }
  },
  "required" => ["id", "effectReference", "inputRecipes", "startLevel"],
  "additionalProperties" => false
}

path.write(JSON.pretty_generate(schema) + "\n")
