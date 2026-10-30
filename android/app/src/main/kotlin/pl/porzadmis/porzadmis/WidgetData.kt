package pl.porzadmis.porzadmis

import android.content.Context
import org.json.JSONObject

/** Odczyt danych zapisanych przez aplikację (pakiet home_widget trzyma je w SharedPreferences). */
object WidgetData {
    private const val PREFERENCES = "HomeWidgetPreferences"

    val ROW_IDS = intArrayOf(R.id.widget_row1, R.id.widget_row2, R.id.widget_row3, R.id.widget_row4, R.id.widget_row5)
    val ROW_TEXT_IDS = intArrayOf(R.id.widget_row1_text, R.id.widget_row2_text, R.id.widget_row3_text, R.id.widget_row4_text, R.id.widget_row5_text)
    val ROW_CHECK_IDS = intArrayOf(R.id.widget_row1_check, R.id.widget_row2_check, R.id.widget_row3_check, R.id.widget_row4_check, R.id.widget_row5_check)
    val ROW_ICON_IDS = intArrayOf(R.id.widget_row1_icon, R.id.widget_row2_icon, R.id.widget_row3_icon, R.id.widget_row4_icon, R.id.widget_row5_icon)

    /** Jawne odwołania: odchudzanie zasobów usuwa pliki wyszukiwane tylko po nazwie. */
    private val MINI_ICONS = mapOf(
        "alarm" to R.drawable.mi_alarm,
        "banana" to R.drawable.mi_banana,
        "bread" to R.drawable.mi_bread,
        "broom" to R.drawable.mi_broom,
        "calendar_event" to R.drawable.mi_calendar_event,
        "cleaning_spray" to R.drawable.mi_cleaning_spray,
        "eggs" to R.drawable.mi_eggs,
        "gift" to R.drawable.mi_gift,
        "heart" to R.drawable.mi_heart,
        "laundry" to R.drawable.mi_laundry,
        "milk" to R.drawable.mi_milk,
        "plant_small" to R.drawable.mi_plant_small,
        "tomato" to R.drawable.mi_tomato,
    )

    fun read(context: Context, key: String): JSONObject? {
        val raw = context.getSharedPreferences(PREFERENCES, Context.MODE_PRIVATE).getString(key, null)
            ?: return null
        return try {
            JSONObject(raw)
        } catch (_: Exception) {
            null
        }
    }

    /** Mini-ikona z paczki albo 0, gdy brak. */
    fun miniIcon(name: String?): Int = if (name.isNullOrEmpty()) 0 else (MINI_ICONS[name] ?: 0)
}
