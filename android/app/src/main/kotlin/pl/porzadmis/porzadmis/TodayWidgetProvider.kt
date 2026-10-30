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
 * więc widżet nie potrzebuje sieci. Dotknięcie otwiera ekran Zadania.
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
        val items = data?.optJSONArray("items")
        val count = items?.length() ?: 0
        val open = data?.optInt("open", 0) ?: 0

        views.setImageViewResource(R.id.widget_header_icon, R.drawable.wg_task_list)
        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else "$open")
        for (i in WidgetData.ROW_IDS.indices) {
            if (i < count) {
                val item = items!!.getJSONObject(i)
                val done = item.optBoolean("done", false)
                views.setViewVisibility(WidgetData.ROW_IDS[i], View.VISIBLE)
                views.setTextViewText(WidgetData.ROW_TEXT_IDS[i], item.optString("title"))
                views.setTextColor(
                    WidgetData.ROW_TEXT_IDS[i],
                    context.getColor(if (done) R.color.widget_muted else R.color.widget_text),
                )
                views.setImageViewResource(
                    WidgetData.ROW_CHECK_IDS[i],
                    if (done) R.drawable.wg_check_done else R.drawable.wg_check_empty,
                )
                val icon = WidgetData.miniIcon(context, item.optString("icon", ""))
                if (icon != 0) {
                    views.setViewVisibility(WidgetData.ROW_ICON_IDS[i], View.VISIBLE)
                    views.setImageViewResource(WidgetData.ROW_ICON_IDS[i], icon)
                } else {
                    views.setViewVisibility(WidgetData.ROW_ICON_IDS[i], View.GONE)
                }
            } else {
                views.setViewVisibility(WidgetData.ROW_IDS[i], View.GONE)
            }
        }
        val empty = count == 0
        views.setViewVisibility(R.id.widget_empty_box, if (empty) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_empty, data?.optString("emptyText") ?: "")

        val next = data?.optString("nextEvent") ?: ""
        views.setViewVisibility(R.id.widget_next, if (next.isEmpty()) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.widget_next, next)

        val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://chores"))
        views.setOnClickPendingIntent(R.id.widget_root, intent)
        return views
    }
}
