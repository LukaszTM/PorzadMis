package pl.porzadmis.porzadmis

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Paint
import android.graphics.Path
import android.graphics.RectF
import android.view.View
import android.widget.RemoteViews

/**
 * Kolory widżetów = tokeny motywu wybranego w aplikacji (zapis `widget_theme`).
 * Kształty w layoutach są białe i tu dostają kolor przez `setColorFilter`; pierścień i ptaszki
 * rysowane są jako bitmapy, żeby też były w kolorze motywu.
 */
class WidgetTheme(
    val background: Int,
    val surface: Int,
    val text: Int,
    val muted: Int,
    val border: Int,
    val accent: Int,
    val accentSoft: Int,
    val onAccent: Int,
) {
    companion object {
        fun load(context: Context): WidgetTheme {
            val j = WidgetData.read(context, "widget_theme")
            // Dart zapisuje ARGB jako liczbę do 0xFFFFFFFF, więc czytamy Long i zwężamy do Int.
            fun c(key: String, fallback: Int) = if (j != null && j.has(key)) j.getLong(key).toInt() else fallback
            return WidgetTheme(
                background = c("background", context.getColor(R.color.widget_accent_soft)),
                surface = c("surface", context.getColor(R.color.widget_surface)),
                text = c("text", context.getColor(R.color.widget_text)),
                muted = c("muted", context.getColor(R.color.widget_muted)),
                border = c("border", context.getColor(R.color.widget_border)),
                accent = c("accent", context.getColor(R.color.widget_accent)),
                accentSoft = c("accentSoft", context.getColor(R.color.widget_accent_soft)),
                onAccent = c("onAccent", 0xFFFFFFFF.toInt()),
            )
        }
    }

    private fun tint(views: RemoteViews, id: Int, color: Int) = views.setInt(id, "setColorFilter", color)

    /** Tło, poświata i obwódka wspólne dla każdego widżetu. */
    fun applyFrame(views: RemoteViews) {
        tint(views, R.id.widget_bg_fill, background)
        tint(views, R.id.widget_bg_glow, accentSoft)
        tint(views, R.id.widget_bg_border, border)
    }

    /** Karta z wierszami, plakietka licznika i przycisk „+” (widżety Dziś i Zakupy). */
    fun applyCard(views: RemoteViews) {
        tint(views, R.id.widget_card_bg, surface)
        tint(views, R.id.widget_badge_bg, accentSoft)
        views.setTextColor(R.id.widget_counter, accent)
        tint(views, R.id.widget_add_bg, accent)
        tint(views, R.id.widget_add_icon, onAccent)
        views.setTextColor(R.id.widget_empty, muted)
        views.setTextColor(R.id.widget_next, muted)
    }

    /** Jeden wiersz listy: ptaszek, emoji i tekst (przekreślony kolorem, gdy zrobione). */
    fun applyRow(context: Context, views: RemoteViews, i: Int, title: String, emoji: String, done: Boolean) {
        views.setViewVisibility(WidgetData.ROW_IDS[i], View.VISIBLE)
        views.setTextViewText(WidgetData.ROW_TEXT_IDS[i], title)
        views.setTextColor(WidgetData.ROW_TEXT_IDS[i], if (done) muted else text)
        views.setTextViewText(WidgetData.ROW_EMOJI_IDS[i], emoji)
        views.setImageViewBitmap(WidgetData.ROW_CHECK_IDS[i], check(context, done))
    }

    private fun dp(context: Context, v: Float) = v * context.resources.displayMetrics.density

    /** Kwadrat z zaokrągleniem: pusty (obrys) albo wypełniony akcentem z ptaszkiem-uśmiechem. */
    fun check(context: Context, done: Boolean): Bitmap {
        val size = dp(context, 22f).toInt()
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val stroke = dp(context, 2f)
        val r = dp(context, 7f)
        val box = RectF(stroke, stroke, size - stroke, size - stroke)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        if (done) {
            paint.color = accent
            paint.style = Paint.Style.FILL
            canvas.drawRoundRect(box, r, r, paint)
            paint.color = onAccent
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = stroke
            paint.strokeCap = Paint.Cap.ROUND
            paint.strokeJoin = Paint.Join.ROUND
            val path = Path()
            path.moveTo(size * 0.28f, size * 0.52f)
            path.lineTo(size * 0.44f, size * 0.68f)
            path.lineTo(size * 0.73f, size * 0.36f)
            canvas.drawPath(path, paint)
        } else {
            paint.color = muted
            paint.style = Paint.Style.STROKE
            paint.strokeWidth = stroke
            canvas.drawRoundRect(box, r, r, paint)
        }
        return bmp
    }

    /** Pierścień postępu 0–100 % w kolorach motywu (tor = obwódka, postęp = akcent). */
    fun ring(context: Context, percent: Int): Bitmap {
        val size = dp(context, 80f).toInt()
        val bmp = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bmp)
        val width = dp(context, 7f)
        val rect = RectF(width, width, size - width, size - width)
        val paint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            style = Paint.Style.STROKE
            strokeWidth = width
            strokeCap = Paint.Cap.ROUND
        }
        paint.color = border
        canvas.drawOval(rect, paint)
        if (percent > 0) {
            paint.color = accent
            canvas.drawArc(rect, -90f, 360f * percent.coerceIn(0, 100) / 100f, false, paint)
        }
        return bmp
    }
}
