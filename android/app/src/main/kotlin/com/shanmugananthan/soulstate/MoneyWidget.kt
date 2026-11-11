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

class MoneyWidget : GlanceAppWidget() {

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

        val data = MoneyPayload.raw(context)
        val balance = data?.optString("balance", "₹0.00") ?: "₹0.00"
        val income = data?.optString("income", "₹0.00") ?: "₹0.00"
        val expense = data?.optString("expense", "₹0.00") ?: "₹0.00"
        val month = data?.optString("month", "") ?: ""
        val todayExpense = data?.optString("todayExpense", "") ?: ""

        Column(
            modifier = GlanceModifier
                .fillMaxSize()
                .padding(pad.dp)
                .clickable(openPageAction(context, "money")),
        ) {
            // Header
            Row(
                modifier = GlanceModifier.fillMaxWidth(),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                val title = "Money Tracker"
                Drawn(WidgetDraw.text(context, title, 14f, style.content, 800, width - 90f), density, title)
                Spacer(GlanceModifier.defaultWeight())
                if (month.isNotEmpty()) {
                    Drawn(WidgetDraw.text(context, month, 11f, style.muted, 600), density, month)
                }
            }

            Spacer(GlanceModifier.height(6.dp))

            // Large Balance
            val label = "Remaining Balance"
            Drawn(WidgetDraw.text(context, label, 10f, style.muted, 600), density, label)
            Spacer(GlanceModifier.height(2.dp))
            Drawn(WidgetDraw.text(context, balance, 19f, style.content, 900, width - 28f), density, balance)

            Spacer(GlanceModifier.height(8.dp))

            // Income & Expense row in rounded container
            Row(
                modifier = GlanceModifier
                    .fillMaxWidth()
                    .cornerRadius(10.dp)
                    .background(ColorProvider(style.content.copy(alpha = 0.08f)))
                    .padding(vertical = 6.dp, horizontal = 10.dp),
                verticalAlignment = Alignment.CenterVertically,
            ) {
                // Income
                Column(modifier = GlanceModifier.defaultWeight()) {
                    val inLabel = "Income"
                    Drawn(WidgetDraw.text(context, inLabel, 9.5f, style.muted, 600), density, inLabel)
                    Spacer(GlanceModifier.height(1.dp))
                    Drawn(WidgetDraw.text(context, "+$income", 11.5f, Color(0xFF10B981), 700), density, income)
                }

                // Expense
                Column(modifier = GlanceModifier.defaultWeight()) {
                    val exLabel = "Expense"
                    Drawn(WidgetDraw.text(context, exLabel, 9.5f, style.muted, 600), density, exLabel)
                    Spacer(GlanceModifier.height(1.dp))
                    Drawn(WidgetDraw.text(context, "-$expense", 11.5f, Color(0xFFEF4444), 700), density, expense)
                }

                if (todayExpense.isNotEmpty() && width >= 240f) {
                    Column(modifier = GlanceModifier.defaultWeight()) {
                        val tLabel = "Today"
                        Drawn(WidgetDraw.text(context, tLabel, 9.5f, style.muted, 600), density, tLabel)
                        Spacer(GlanceModifier.height(1.dp))
                        Drawn(WidgetDraw.text(context, "-$todayExpense", 11.5f, style.content, 700), density, todayExpense)
                    }
                }
            }
        }
    }
}
