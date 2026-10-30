package pl.porzadmis.porzadmis

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONObject

/** Widżet „Zakupy”: pierścień postępu (kupione / wszystkie) z koszykiem, lista do 5 nazw, „+” otwiera listę. */
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
        val bought = data?.optInt("bought", 0) ?: 0
        val total = count + bought
        views.setProgressBar(R.id.widget_ring, 100, if (total == 0) 0 else bought * 100 / total, false)
        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else "$count")
        views.setViewVisibility(R.id.widget_counter, if (count == 0) View.GONE else View.VISIBLE)
        for (i in WidgetData.ROW_IDS.indices) {
            if (names != null && i < names.length()) {
                views.setViewVisibility(WidgetData.ROW_IDS[i], View.VISIBLE)
                views.setTextViewText(WidgetData.ROW_TEXT_IDS[i], names.getString(i))
                views.setImageViewResource(WidgetData.ROW_CHECK_IDS[i], R.drawable.wg_check_empty)
                val icon = WidgetData.miniIcon(icons?.optString(i, "") ?: "")
                views.setViewVisibility(WidgetData.ROW_ICON_IDS[i], if (icon != 0) View.VISIBLE else View.GONE)
                if (icon != 0) views.setImageViewResource(WidgetData.ROW_ICON_IDS[i], icon)
            } else {
                views.setViewVisibility(WidgetData.ROW_IDS[i], View.GONE)
            }
        }
        views.setViewVisibility(R.id.widget_empty_box, if (count == 0) View.VISIBLE else View.GONE)
        views.setTextViewText(R.id.widget_empty, data?.optString("emptyText") ?: "")
        views.setViewVisibility(R.id.widget_next, View.GONE)

        views.setOnClickPendingIntent(R.id.widget_root, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://shopping")))
        views.setOnClickPendingIntent(R.id.widget_add, HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://shopping?add=1")))
        return views
    }
}
