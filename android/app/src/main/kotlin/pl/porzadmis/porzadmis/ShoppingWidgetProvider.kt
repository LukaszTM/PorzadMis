package pl.porzadmis.porzadmis

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import org.json.JSONObject

/** Widżet „Zakupy”: pierścień postępu (kupione / wszystkie) z koszykiem, lista do 5 nazw z emoji, „+” otwiera listę. */
class ShoppingWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val json = WidgetData.read(context, "widget_shopping")
        val theme = WidgetTheme.load(context)
        for (id in ids) {
            manager.updateAppWidget(id, build(context, json, theme))
        }
    }

    private fun build(context: Context, data: JSONObject?, theme: WidgetTheme): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.widget_shopping)
        theme.applyFrame(views)
        theme.applyCard(views)
        val names = data?.optJSONArray("names")
        val emoji = data?.optJSONArray("emoji")
        val count = data?.optInt("count", 0) ?: 0
        val bought = data?.optInt("bought", 0) ?: 0
        val total = count + bought
        views.setImageViewBitmap(R.id.widget_ring, theme.ring(context, if (total == 0) 0 else bought * 100 / total))
        views.setTextViewText(R.id.widget_counter, if (count == 0) "" else "$count")
        views.setViewVisibility(R.id.widget_counter, if (count == 0) View.GONE else View.VISIBLE)
        for (i in WidgetData.ROW_IDS.indices) {
            if (names != null && i < names.length()) {
                theme.applyRow(context, views, i, names.getString(i), emoji?.optString(i, "") ?: "", false)
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
