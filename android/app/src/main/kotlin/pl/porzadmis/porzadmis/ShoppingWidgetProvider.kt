package pl.porzadmis.porzadmis

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONObject

/** Widżet „Zakupy” (GUI 5.13): liczba niekupionych i pierwsze 5 nazw; dotknięcie otwiera listę. */
class ShoppingWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val json = WidgetData.read(context, "widget_shopping")
        for (id in ids) {
            manager.updateAppWidget(id, build(context, json))
        }
    }

    private fun build(context: Context, data: JSONObject?): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_shopping)
        val names = data?.optJSONArray("names")
        val count = data?.optInt("count", 0) ?: 0
        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else count.toString())
        for ((i, rowId) in WidgetData.ROW_IDS.withIndex()) {
            if (names != null && i < names.length()) {
                views.setViewVisibility(rowId, View.VISIBLE)
                views.setTextViewText(rowId, "• " + names.getString(i))
            } else {
                views.setViewVisibility(rowId, View.GONE)
            }
        }
        views.setViewVisibility(R.id.widget_empty, if (count == 0) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_empty, data?.optString("emptyText") ?: "")
        views.setViewVisibility(R.id.widget_next, View.GONE)

        val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://shopping"))
        views.setOnClickPendingIntent(R.id.widget_root, intent)
        return views
    }
}
