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
import androidx.glance.layout.width
import androidx.glance.unit.ColorProvider

class DashboardWidget : GlanceAppWidget() {

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

        val data = DashboardPayload.raw(context)
        val habitsDone = data?.optInt("habitsDone", 0) ?: 0
        val habitsTotal = data?.optInt("habitsTotal", 0) ?: 0
        val habitsPct = if (habitsTotal > 0) (habitsDone * 100 / habitsTotal) else 0
        val todosOpen = data?.optInt("todosOpen", 0) ?: 0
        val moneyBalance = data?.optString("moneyBalance", "₹0") ?: "₹0"
        val mealsLogged = data?.optInt("mealsLogged", 0) ?: 0
        val calories = data?.optInt("calories", 0) ?: 0

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(pad.dp)
                .clickable(openPageAction(context, "")),
        ) {
            // Header: Title and Completion Badge
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                Row(
                    modifier = GlanceModifier.defaultWeight(),
                    verticalAlignment = Alignment.CenterVertically,
                ) {
                    Flame(size = 18.dp)
                    Spacer(GlanceModifier.width(6.dp))
                    val title = "Dashboard"
                    Drawn(WidgetDraw.text(context, title, 14.5f, style.content, 800, width - 100f), density, title)
                }
                val pctText = "$habitsPct% Done"
                Box(
                    modifier = GlanceModifier
                        .cornerRadius(6.dp)
                        .background(ColorProvider(Color(0x3310B981)))
                        .padding(horizontal = 7.dp, vertical = 2.dp),
                ) {
                    Drawn(WidgetDraw.text(context, pctText, 10.5f, Color(0xFF10B981), 700), density, pctText)
                }
            }

            Spacer(GlanceModifier.height(8.dp))

            // 3 Stat Columns in a rounded card
            Row(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .cornerRadius(12.dp)
                    .background(ColorProvider(style.content.copy(alpha = 0.08f)))
                    .padding(vertical = 8.dp, horizontal = 6.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Habits
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    val label = "Habits"
                    val value = "$habitsDone / $habitsTotal"
                    Drawn(WidgetDraw.text(context, label, 10f, style.muted, 600), density, label)
                    Spacer(GlanceModifier.height(2.dp))
                    Drawn(WidgetDraw.text(context, value, 12.5f, style.content, 800), density, value)
                }

                // Divider
                Box(modifier = GlanceModifier.width(1.dp).height(24.dp).background(ColorProvider(style.content.copy(alpha = 0.12f)))) {}

                // Tasks
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    val label = "Tasks"
                    val value = "$todosOpen open"
                    Drawn(WidgetDraw.text(context, label, 10f, style.muted, 600), density, label)
                    Spacer(GlanceModifier.height(2.dp))
                    Drawn(WidgetDraw.text(context, value, 12.5f, style.content, 800), density, value)
                }

                // Divider
                Box(modifier = GlanceModifier.width(1.dp).height(24.dp).background(ColorProvider(style.content.copy(alpha = 0.12f)))) {}

                // Money
                Column(
                    modifier = GlanceModifier.defaultWeight(),
                    horizontalAlignment = Alignment.CenterHorizontally,
                ) {
                    val label = "Balance"
                    Drawn(WidgetDraw.text(context, label, 10f, style.muted, 600), density, label)
                    Spacer(GlanceModifier.height(2.dp))
                    Drawn(WidgetDraw.text(context, moneyBalance, 12.5f, style.content, 800), density, moneyBalance)
                }
            }

            Spacer(GlanceModifier.height(8.dp))

            // Bottom row: Meals & Calorie progress
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                val mealsSummary = "Meals: $mealsLogged logged" + if (calories > 0) " · $calories kcal" else ""
                Drawn(WidgetDraw.text(context, mealsSummary, 11f, style.muted, 600, width - 28f), density, mealsSummary)
            }
        }
    }
}
