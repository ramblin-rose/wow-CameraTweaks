import gulp from "gulp";
import path from "node:path";
import { readFileSync } from "node:fs";
import zip from "gulp-zip";
import { deleteAsync } from "del";

// Read version from package.json
const packageJson = JSON.parse(readFileSync("./package.json", "utf8"));
const version = packageJson.version;
const ADDON_NAME = "Camera";

// Source glob – only the required extensions, recursive
const SRC_GLOB = "src/**/*.{xml,lua,png,toc}";

/**
 * Resolve the live WoW Classic AddOns destination path.
 * Uses path.join so separators are correct on Windows.
 */
function getLiveDest() {
  const envPath = process.env.WOW_CLASSIC_ADDON_PATH;
  if (!envPath) {
    throw new Error(
      "Environment variable WOW_CLASSIC_ADDON_PATH is not set!\n" +
        'Example (PowerShell): $env:WOW_CLASSIC_ADDON_PATH = "C:\\Program Files (x86)\\World of Warcraft\\_classic_\\Interface\\AddOns"',
    );
  }
  return path.join(envPath, ADDON_NAME);
}

/**
 * Copy matching files from src/ → live WoW AddOns/Camera/
 * { encoding: false } is required so .png (binary) files are not corrupted.
 */
export function copy() {
  const dest = getLiveDest();
  console.log(`[copy] → ${dest}`);
  return gulp
    .src(SRC_GLOB, { base: "src", encoding: false })
    .pipe(gulp.dest(dest));
}

/**
 * Default / watch task: initial copy + watch for changes.
 */
export function watchFiles() {
  // Run once immediately
  copy();

  // Watch and re-copy on any change
  return gulp.watch(SRC_GLOB, copy);
}

/**
 * BUILD TASK
 * 1. Clean previous build artefacts
 * 2. Create a clean folder named after the version (e.g. build/1.2.3/)
 * 3. Copy the exact same content that goes into the live addon folder
 * 4. Zip it as Camera-<version>.zip
 */
export function cleanBuild() {
  return deleteAsync(["build", "dist"]);
}

export function buildCopy() {
  const versionDir = path.join("build", version); // e.g. build/1.2.3
  console.log(`[build] Creating clean folder: ${versionDir}`);
  return gulp
    .src(SRC_GLOB, { base: "src", encoding: false })
    .pipe(gulp.dest(versionDir));
}

export function zipBuild() {
  const zipName = `${ADDON_NAME}-${version}.zip`; // Camera-1.2.3.zip
  console.log(`[build] Creating ${zipName}`);
  return gulp
    .src(path.join("build", version, "**/*"), {
      base: "build",
      encoding: false,
    })
    .pipe(zip(zipName))
    .pipe(gulp.dest("dist"));
}

// Public tasks
export const watch = watchFiles;
export const build = gulp.series(cleanBuild, buildCopy, zipBuild);
export default watchFiles; // `gulp` runs the watcher
