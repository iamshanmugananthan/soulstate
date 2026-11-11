package com.shanmugananthan.soulstate

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.unit.ColorProvider

class MealsWidget : GlanceAppWidget() {

    override val sizeMode = SizeMode.Exact

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val appWidgetId = GlanceAppWidgetManager(context).getAppWidgetId(id)
        provideContent {
            currentState(GlanceWidgets.REVISION)
            val style = WidgetStyle.loadFor(context, appWidgetId)
            WidgetSurface(style, radius = 22.dp) { Body(context, style) }
        }
    }

    @Composable
    private fun Body(context: Context, style: WidgetStyle) {
        val density = WidgetDraw.density(context)
        val size = LocalSize.current
        val width = size.width.value
        val pad = if (width < 220f) 10f else 14f

        val data = MealsPayload.raw(context)
        val calories = data?.optInt("calories", 0) ?: 0
        val goal = data?.optInt("calorieGoal", 2000) ?: 2000
        val cleanRatio = data?.optInt("cleanRatio", 100) ?: 100
        val mealCount = data?.optInt("mealCount", 0) ?: 0
        val water = data?.optInt("waterGlasses", 0) ?: 0

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(pad.dp)
                .clickable(openPageAction(context, "meals")),
        ) {
            // Header
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                val title = "Meal Tracker"
                Drawn(WidgetDraw.text(context, title, 14f, style.content, 800, width - 90f), density, title)
                Spacer(GlanceModifier.defaultWeight())
                val cleanBadge = "$cleanRatio% Clean"
                Box(
                    modifier = GlanceModifier
                        .cornerRadius(6.dp)
                        .background(ColorProvider(Color(0x3310B981)))
                        .padding(horizontal = 6.dp, vertical = 2.dp),
                ) {
                    Drawn(WidgetDraw.text(context, cleanBadge, 10.5f, Color(0xFF10B981), 700), density, cleanBadge)
                }
            }

            Spacer(GlanceModifier.height(6.dp))

            // Calories logged / goal
            val calLabel = "Calories Logged"
            Drawn(WidgetDraw.text(context, calLabel, 10f, style.muted, 600), density, calLabel)
            Spacer(GlanceModifier.height(2.dp))
            val calValue = "$calories / $goal kcal"
            Drawn(WidgetDraw.text(context, calValue, 18f, style.content, 900, width - 28f), density, calValue)

            Spacer(GlanceModifier.height(8.dp))

            // Metrics row in rounded card
            Row(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .cornerRadius(10.dp)
                    .background(ColorProvider(style.content.copy(alpha = 0.08f)))
                    .padding(vertical = 6.dp, horizontal = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Meals count
                Column(modifier = GlanceModifier.defaultWeight()) {
                    val mLabel = "Meals"
                    val mVal = "$mealCount logged"
                    Drawn(WidgetDraw.text(context, mLabel, 9.5f, style.muted, 600), density, mLabel)
                    Spacer(GlanceModifier.height(1.dp))
                    Drawn(WidgetDraw.text(context, mVal, 12f, style.content, 700), density, mVal)
                }

                // Water glasses
                Column(modifier = GlanceModifier.defaultWeight()) {
                    val wLabel = "Water"
                    val wVal = "$water glasses"
                    Drawn(WidgetDraw.text(context, wLabel, 9.5f, style.muted, 600), density, wLabel)
                    Spacer(GlanceModifier.height(1.dp))
                    Drawn(WidgetDraw.text(context, wVal, 12f, Color(0xFF38B6FF), 700), density, wVal)
                }
            }
        }
    }
}
