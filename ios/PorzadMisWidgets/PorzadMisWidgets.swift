import SwiftUI
import WidgetKit

// Widżety PorządMiś na iOS (WidgetKit). Czytają te same dane co widżety Androida: aplikacja zapisuje
// JSON przez home_widget do wspólnego kontenera (App Group). Widżety nigdy nie pokazują budżetu.
// UWAGA: kod napisany bez Maca i nieuruchomiony; wymaga sprawdzenia w Xcode / na iPhonie.

private let appGroupId = "group.pl.porzadmis.porzadmis"

// MARK: - Dane

private func readJSON(_ key: String) -> [String: Any] {
    guard let raw = UserDefaults(suiteName: appGroupId)?.string(forKey: key),
          let data = raw.data(using: .utf8),
          let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return [:] }
    return obj
}

/// Kolory motywu wybranego w aplikacji (ARGB zapisane jako liczba).
struct WidgetPalette {
    let background: Color
    let surface: Color
    let text: Color
    let muted: Color
    let border: Color
    let accent: Color
    let accentSoft: Color
    let onAccent: Color

    static func load() -> WidgetPalette {
        let j = readJSON("widget_theme")
        func color(_ key: String, _ fallback: UInt32) -> Color {
            let v = (j[key] as? NSNumber)?.uint32Value ?? fallback
            return Color(
                .sRGB,
                red: Double((v >> 16) & 0xFF) / 255,
                green: Double((v >> 8) & 0xFF) / 255,
                blue: Double(v & 0xFF) / 255,
                opacity: Double((v >> 24) & 0xFF) / 255
            )
        }
        return WidgetPalette(
            background: color("background", 0xFFFBF7F1),
            surface: color("surface", 0xFFFFFFFF),
            text: color("text", 0xFF1C2733),
            muted: color("muted", 0xFF5B6773),
            border: color("border", 0xFFE3DCD0),
            accent: color("accent", 0xFF2B7A57),
            accentSoft: color("accentSoft", 0xFFDDEFE5),
            onAccent: color("onAccent", 0xFFFFFFFF)
        )
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    let palette: WidgetPalette
    let data: [String: Any]
}

struct WidgetProvider: TimelineProvider {
    let key: String

    func placeholder(in context: Context) -> WidgetEntry {
        WidgetEntry(date: Date(), palette: WidgetPalette.load(), data: [:])
    }

    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        completion(WidgetEntry(date: Date(), palette: WidgetPalette.load(), data: readJSON(key)))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let entry = WidgetEntry(date: Date(), palette: WidgetPalette.load(), data: readJSON(key))
        // Aplikacja odświeża widżety przy zmianach; to tylko zapas, gdy aplikacja jest zamknięta.
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

// MARK: - Wspólne elementy

private extension View {
    /// Tło widżetu: od iOS 17 wymagane przez `containerBackground`, wcześniej zwykła warstwa.
    @ViewBuilder
    func widgetBackground(_ color: Color) -> some View {
        if #available(iOS 17.0, *) {
            self.containerBackground(color, for: .widget)
        } else {
            self.padding().background(color)
        }
    }
}

private struct CheckBox: View {
    let done: Bool
    let palette: WidgetPalette

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(done ? palette.accent : Color.clear)
            RoundedRectangle(cornerRadius: 6)
                .stroke(done ? palette.accent : palette.muted, lineWidth: 2)
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: 11, weight: .heavy))
                    .foregroundColor(palette.onAccent)
            }
        }
        .frame(width: 20, height: 20)
    }
}

private struct AddButton: View {
    let url: String
    let palette: WidgetPalette

    var body: some View {
        Link(destination: URL(string: url)!) {
            ZStack {
                Circle().fill(palette.accent)
                Image(systemName: "plus")
                    .font(.system(size: 14, weight: .heavy))
                    .foregroundColor(palette.onAccent)
            }
            .frame(width: 30, height: 30)
        }
    }
}

private struct Badge: View {
    let text: String
    let palette: WidgetPalette

    var body: some View {
        Text(text)
            .font(.system(size: 13, weight: .heavy, design: .rounded))
            .foregroundColor(palette.accent)
            .padding(.horizontal, 9)
            .padding(.vertical, 3)
            .background(Capsule().fill(palette.accentSoft))
    }
}

// MARK: - Dziś (obowiązki)

struct TodayView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WidgetEntry

    private var items: [[String: Any]] { entry.data["items"] as? [[String: Any]] ?? [] }
    private var open: Int { (entry.data["open"] as? NSNumber)?.intValue ?? 0 }
    private var next: String { entry.data["nextEvent"] as? String ?? "" }
    private var emptyText: String { entry.data["emptyText"] as? String ?? "" }

    var body: some View {
        let p = entry.palette
        let limit = family == .systemSmall ? 3 : 5
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Dziś")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(p.text)
                Spacer()
                Badge(text: "\(open)", palette: p)
                if family != .systemSmall {
                    AddButton(url: "porzadmis://chores?add=1", palette: p)
                }
            }
            if items.isEmpty {
                Spacer()
                Text(emptyText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(p.muted)
                Spacer()
            } else {
                ForEach(Array(items.prefix(limit).enumerated()), id: \.offset) { _, item in
                    let done = item["done"] as? Bool ?? false
                    HStack(spacing: 8) {
                        CheckBox(done: done, palette: p)
                        Text(item["emoji"] as? String ?? "")
                            .font(.system(size: 14))
                        Text(item["title"] as? String ?? "")
                            .font(.system(size: 14, weight: .semibold))
                            .strikethrough(done)
                            .foregroundColor(done ? p.muted : p.text)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
            if family != .systemSmall && !next.isEmpty {
                Text(next)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(p.muted)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "porzadmis://chores"))
        .widgetBackground(p.surface)
    }
}

struct TodayWidget: Widget {
    let kind = "PorzadMisToday"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider(key: "widget_today")) { entry in
            TodayView(entry: entry)
        }
        .configurationDisplayName("Dziś")
        .description("Twoje obowiązki na dziś.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Zakupy

struct ShoppingView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WidgetEntry

    private var count: Int { (entry.data["count"] as? NSNumber)?.intValue ?? 0 }
    private var names: [String] { entry.data["names"] as? [String] ?? [] }
    private var emoji: [String] { entry.data["emoji"] as? [String] ?? [] }
    private var emptyText: String { entry.data["emptyText"] as? String ?? "" }

    var body: some View {
        let p = entry.palette
        let limit = family == .systemSmall ? 3 : 5
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Zakupy")
                    .font(.system(size: 15, weight: .heavy, design: .rounded))
                    .foregroundColor(p.text)
                Spacer()
                Badge(text: "\(count)", palette: p)
                if family != .systemSmall {
                    AddButton(url: "porzadmis://shopping?add=1", palette: p)
                }
            }
            if names.isEmpty {
                Spacer()
                Text(emptyText)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(p.muted)
                Spacer()
            } else {
                ForEach(Array(names.prefix(limit).enumerated()), id: \.offset) { index, name in
                    HStack(spacing: 8) {
                        CheckBox(done: false, palette: p)
                        Text(index < emoji.count ? emoji[index] : "")
                            .font(.system(size: 14))
                        Text(name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(p.text)
                            .lineLimit(1)
                    }
                }
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "porzadmis://shopping"))
        .widgetBackground(p.surface)
    }
}

struct ShoppingWidget: Widget {
    let kind = "PorzadMisShopping"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider(key: "widget_shopping")) { entry in
            ShoppingView(entry: entry)
        }
        .configurationDisplayName("Zakupy")
        .description("Co zostało do kupienia na liście Zakupy.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Kalendarz (najbliższe wydarzenie)

struct CalendarView: View {
    let entry: WidgetEntry

    var body: some View {
        let p = entry.palette
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.data["today"] as? String ?? "")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(p.muted)
                .lineLimit(1)
            Spacer(minLength: 0)
            Text(entry.data["title"] as? String ?? "")
                .font(.system(size: 17, weight: .heavy, design: .rounded))
                .foregroundColor(p.text)
                .lineLimit(2)
            Text(entry.data["when"] as? String ?? "")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(p.accent)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .widgetURL(URL(string: "porzadmis://calendar"))
        .widgetBackground(p.accentSoft)
    }
}

struct CalendarWidget: Widget {
    let kind = "PorzadMisCalendar"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WidgetProvider(key: "widget_calendar")) { entry in
            CalendarView(entry: entry)
        }
        .configurationDisplayName("Kalendarz")
        .description("Najbliższe wydarzenie w domu.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// MARK: - Pakiet

@main
struct PorzadMisWidgetsBundle: WidgetBundle {
    var body: some Widget {
        TodayWidget()
        ShoppingWidget()
        CalendarWidget()
    }
}
