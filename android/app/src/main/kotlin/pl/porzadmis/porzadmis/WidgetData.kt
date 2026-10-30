package pl.porzadmis.porzadmis

import android.content.Context
import org.json.JSONObject

/** Odczyt danych zapisanych przez aplikację (pakiet home_widget trzyma je w SharedPreferences). */
object WidgetData {
    private const val PREFERENCES = "HomeWidgetPreferences"

    val ROW_IDS = intArrayOf(R.id.widget_row1, R.id.widget_row2, R.id.widget_row3, R.id.widget_row4, R.id.widget_row5)

    fun read(context: Context, key: String): JSONObject? {
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getString(key, null)
            ?: return null
        return try {
            JSONObject(raw)
        } catch (_: Exception) {
            null
        }
    }
}
