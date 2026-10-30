package pl.porzadmis.porzadmis

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent

/** Mały widżet „Kalendarz”: dzisiejsza data i najbliższe wydarzenie domu. */
class CalendarWidgetProvider : AppWidgetProvider() {
    override fun onUpdate(context: Context, manager: AppWidgetManager, ids: IntArray) {
        val data = WidgetData.read(context, "widget_calendar")
        for (id in ids) {
            val views = RemoteViews(context.packageName, R.layout.widget_calendar)
            views.setTextViewText(R.id.widget_date, data?.optString("today") ?: "")
            views.setTextViewText(R.id.widget_event_title, data?.optString("title") ?: "")
            views.setTextViewText(R.id.widget_event_when, data?.optString("when") ?: "")
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java, Uri.parse("porzadmis://calendar")),
            )
            manager.updateAppWidget(id, views)
        }
    }
}
