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
        val icons = data?.optJSONArray("icons")
        val count = data?.optInt("count", 0) ?: 0
        views.setImageViewResource(R.id.widget_header_icon, R.drawable.wg_basket)
        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else "$count")
        for (i in WidgetData.ROW_IDS.indices) {
            if (names != null && i < names.length()) {
                views.setViewVisibility(WidgetData.ROW_IDS[i], View.VISIBLE)
                views.setTextViewText(WidgetData.ROW_TEXT_IDS[i], names.getString(i))
                views.setImageViewResource(WidgetData.ROW_CHECK_IDS[i], R.drawable.wg_check_empty)
                val icon = WidgetData.miniIcon(context, icons?.optString(i, "") ?: "")
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
        views.setViewVisibility(R.id.widget_empty_box, if (count == 0) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_empty, data?.optString("emptyText") ?: "")
        views.setViewVisibility(R.id.widget_next, View.GONE)

        val intent = HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://shopping"))
        views.setOnClickPendingIntent(R.id.widget_root, intent)
        return views
    }
}
