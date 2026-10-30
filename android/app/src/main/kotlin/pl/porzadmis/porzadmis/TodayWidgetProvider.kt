package pl.porzadmis.porzadmis

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONObject

/**
 * Widżet „Dziś” (GUI 5.13): moje obowiązki na dziś (do 5) i najbliższe wydarzenie.
 * Dane zapisuje aplikacja przy każdej synchronizacji (home_widget, klucz `widget_today`),
 * więc widżet nie potrzebuje sieci. Dotknięcie otwiera ekran Obowiązki.
 */
class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val json = WidgetData.read(context, "widget_today")
        for (id in ids) {
            manager.updateAppWidget(id, build(context, json))
        }
    }

    private fun build(context: Context, data: JSONObject?): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_today)
        val rows = WidgetData.ROW_IDS
        val items = data?.optJSONArray("items")
        val count = items?.length() ?: 0
        val open = data?.optInt("open", 0) ?: 0

        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else open.toString())
        for ((i, rowId) in rows.withIndex()) {
            if (i < count) {
                val item = items!!.getJSONObject(i)
                val done = item.optBoolean("done", false)
                val glyph = if (done) "✓ " else "○ "
                views.setViewVisibility(rowId, View.VISIBLE)
                views.setTextViewText(rowId, glyph + item.optString("title"))
                views.setTextColor(
                    rowId,
                    context.getColor(if (done) R.color.widget_muted else R.color.widget_text),
                )
            } else {
                views.setViewVisibility(rowId, View.GONE)
            }
        }
        val empty = count == 0
        views.setViewVisibility(R.id.widget_empty, if (empty) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_empty, data?.optString("emptyText") ?: "")

        val next = data?.optString("nextEvent") ?: ""
        views.setViewVisibility(R.id.widget_next, if (next.isEmpty()) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.widget_next, next)

        val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://chores"))
        views.setOnClickPendingIntent(R.id.widget_root, intent)
        return views
    }
}
