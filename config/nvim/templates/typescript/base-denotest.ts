import { describe, it } from "jsr:@std/testing@1.0.11/bdd";
import { expect } from "jsr:@std/expect@1.0.15";

const add = (lhs: number, rhs: number): number => lhs + rhs;

describe("add", () => {
  it("must return 2 if 1 and 1 was given", () => {
    expect(add(1, 1)).toBe(2);
  });
});
