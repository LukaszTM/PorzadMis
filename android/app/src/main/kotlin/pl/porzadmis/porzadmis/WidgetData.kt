package pl.porzadmis.porzadmis

import android.content.Context
import org.json.JSONObject

/** Odczyt danych zapisanych przez aplikację (pakiet home_widget trzyma je w SharedPreferences). */
object WidgetData {
    private const val PREFERENCES = "HomeWidgetPreferences"

    val ROW_IDS = intArrayOf(R.id.widget_row1, R.id.widget_row2, R.id.widget_row3, R.id.widget_row4, R.id.widget_row5)
    val ROW_TEXT_IDS = intArrayOf(R.id.widget_row1_text, R.id.widget_row2_text, R.id.widget_row3_text, R.id.widget_row4_text, R.id.widget_row5_text)
    val ROW_CHECK_IDS = intArrayOf(R.id.widget_row1_check, R.id.widget_row2_check, R.id.widget_row3_check, R.id.widget_row4_check, R.id.widget_row5_check)
    val ROW_EMOJI_IDS = intArrayOf(R.id.widget_row1_emoji, R.id.widget_row2_emoji, R.id.widget_row3_emoji, R.id.widget_row4_emoji, R.id.widget_row5_emoji)

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
