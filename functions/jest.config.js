module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  roots: ["<rootDir>/test"],
  testTimeout: 20000,
  globals: {},
  transform: {
    "^.+\\.ts$": ["ts-jest", { tsconfig: { module: "commonjs", target: "es2022", esModuleInterop: true, strict: true } }],
  },
};
