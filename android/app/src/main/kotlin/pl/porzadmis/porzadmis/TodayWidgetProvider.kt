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
 * Widżet „Dziś”: miś po lewej (z domkiem, gdy jest co robić; odpoczywa, gdy wszystko zrobione),
 * karta z moimi obowiązkami (do 5), najbliższe wydarzenie, „+” otwiera Zadania. Kolory z motywu aplikacji.
 */
class TodayWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val json = WidgetData.read(context, "widget_today")
        val theme = WidgetTheme.load(context)
        for (id in ids) {
            manager.updateAppWidget(id, build(context, json, theme))
        }
    }

    private fun build(context: Context, data: JSONObject?, theme: WidgetTheme): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_today)
        theme.applyFrame(views)
        theme.applyCard(views)
        val items = data?.optJSONArray("items")
        val count = items?.length() ?: 0
        val open = data?.optInt("open", 0) ?: 0

        views.setImageViewResource(R.id.widget_bear, if (open > 0) R.drawable.wg_bear_house else R.drawable.wg_bear_resting)
        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else "$open/$count")
        views.setViewVisibility(R.id.widget_counter, if (count == 0) View.GONE else View.VISIBLE)
        for (i in WidgetData.ROW_IDS.indices) {
            if (i < count) {
                val item = items!!.getJSONObject(i)
                theme.applyRow(context, views, i, item.optString("title"), item.optString("emoji"), item.optBoolean("done", false))
            } else {
                views.setViewVisibility(WidgetData.ROW_IDS[i], View.GONE)
            }
        }
        views.setViewVisibility(R.id.widget_empty_box, if (count == 0) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_empty, data?.optString("emptyText") ?: "")

        val next = data?.optString("nextEvent") ?: ""
        views.setViewVisibility(R.id.widget_next, if (next.isEmpty()) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.widget_next, next)

        views.setOnClickPendingIntent(R.id.widget_root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://chores")))
        views.setOnClickPendingIntent(R.id.widget_add, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://chores?add=1")))
        return views
    }
}
