module.exports = {
  preset: "ts-jest",
  testEnvironment: "node",
  testTimeout: 60000,
  roots: ["."],
  testMatch: ["**/*.test.ts"],
  moduleFileExtensions: ["ts", "js", "json"],
};
