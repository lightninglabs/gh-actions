import * as glob from "glob";
import { lstatSync, readFileSync } from "fs";

export interface Config {
  github_token: string;
  github_ref: string;
  github_repository: string;
  // user provided
  input_name?: string;
  input_tag_name?: string;
  input_body?: string;
  input_body_path?: string;
  input_files?: string[];
  input_draft?: boolean;
  input_prerelease?: boolean;
}

export const releaseBody = (config: Config): string | undefined => {
  return (
    config.input_body ||
    (config.input_body_path &&
      readFileSync(config.input_body_path).toString("utf8"))
  );
};

type Env = { [key: string]: string | undefined };

export const parseInputFiles = (files: string): string[] => {
  return files.split(/\r?\n/).reduce<string[]>(
    (acc, line) =>
      acc
        .concat(line.split(","))
        .filter(pat => pat)
        .map(pat => pat.trim()),
    []
  );
};

export const parseConfig = (env: Env): Config => {
  return {
    github_token: env.GITHUB_TOKEN || "",
    github_ref: env.GITHUB_REF || "",
    github_repository: env.GITHUB_REPOSITORY || "",
    input_name: env.INPUT_NAME,
    input_tag_name: env.INPUT_TAG_NAME,
    input_body: env.INPUT_BODY,
    input_body_path: env.INPUT_BODY_PATH,
    input_files: parseInputFiles(env.INPUT_FILES || ""),
    input_draft: env.INPUT_DRAFT === "true",
    input_prerelease: env.INPUT_PRERELEASE == "true"
  };
};

export const paths = (patterns: string[]): string[] => {
  return patterns.reduce((acc: string[], pattern: string): string[] => {
    return acc.concat(
      glob.sync(pattern).filter(path => lstatSync(path).isFile())
    );
  }, []);
};

export const isTag = (ref: string): boolean => {
  return ref.startsWith("refs/tags/");
};
