import ts from "@typescript-eslint/eslint-plugin"
import tsParser from "@typescript-eslint/parser"
import prettier from "eslint-config-prettier"
import airbnbBase from "eslint-config-airbnb-base"
import airbnb from "eslint-config-airbnb-typescript-base"

export default [
  {
    rules: {
      complexity: ["warn", { max: 15 }],
    },
  },
  {
    files: ["**/*.ts"],
    plugins: {
      "@typescript-eslint": ts,
    },
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: "latest",
        sourceType: "module",
        project: "./tsconfig.json",
      }
    },
    rules: {
      ...ts.configs["recommended"].rules,
      ...ts.configs["eslint-recommended"].rules,
      ...airbnbBase.rules,
      ...airbnb.rules,
      "@typescript-eslint/no-unused-vars": [
        "error",
        {
          argsIgnorePattern: "^_",
          varsIgnorePattern: "^_",
          caughtErrorsIgnorePattern: "^_",
          destructuredArrayIgnorePattern: "^_",
        },
      ],
    },
  },
  {
    rules: {
      ...prettier.rules,
    },
  },
]
