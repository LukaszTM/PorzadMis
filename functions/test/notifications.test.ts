import { crossedPlan, formatPln, messages, prefEnabled } from "../src/notifications";

describe("prefEnabled", () => {
  test("domyślnie wszystko włączone poza zakupami", () => {
    expect(prefEnabled(undefined, "chores")).toBe(true);
    expect(prefEnabled(undefined, "shopping")).toBe(false);
    expect(prefEnabled({}, "budget")).toBe(true);
  });
  test("jawne ustawienie wygrywa z domyślnym", () => {
    expect(prefEnabled({ chores: false }, "chores")).toBe(false);
    expect(prefEnabled({ shopping: true }, "shopping")).toBe(true);
    expect(prefEnabled({ shopping: "tak" }, "shopping")).toBe(false);
  });
});

describe("crossedPlan", () => {
  test("tylko pierwsze przekroczenie", () => {
    expect(crossedPlan(900, 1100, 1000)).toBe(true);
    expect(crossedPlan(1100, 1300, 1000)).toBe(false);
    expect(crossedPlan(500, 900, 1000)).toBe(false);
    expect(crossedPlan(1000, 1001, 1000)).toBe(true);
  });
  test("bez planu nigdy", () => {
    expect(crossedPlan(0, 100, 0)).toBe(false);
  });
});

describe("treści", () => {
  test("komunikaty po polsku, bez wykrzykników, z trasą deep linku", () => {
    const all = [
      messages.choreAssigned("Śmieci", "Ala"),
      messages.choreAssigned("Śmieci", ""),
      messages.memberJoined("Tomek"),
      messages.shoppingAdded("mleko", "Ala"),
      messages.budgetExceeded("2026-11", formatPln(210000), formatPln(200000)),
    ];
    for (const m of all) {
      expect(m.title + m.body).not.toContain("!");
      expect(m.route.startsWith("/")).toBe(true);
    }
    expect(all[0].body).toBe("Ala przypisał(a) go Tobie.");
    expect(all[4].body).toBe("W tym miesiącu wydano 2 100,00 zł z 2 000,00 zł.");
  });
  test("formatPln", () => {
    expect(formatPln(142050)).toBe("1 420,50 zł");
    expect(formatPln(5)).toBe("0,05 zł");
  });
});
