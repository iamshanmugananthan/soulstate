package com.shanmugananthan.soulstate

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.glance.appwidget.GlanceAppWidgetReceiver

class MealsWidgetProvider : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = MealsWidget()

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        WidgetRefreshReceiver.keepFresh(context)
        GlanceWidgets.refreshSoon(context, glanceAppWidget, appWidgetIds, goAsync())
    }

    override fun onDeleted(context: Context, appWidgetIds: IntArray) {
        super.onDeleted(context, appWidgetIds)
        for (id in appWidgetIds) WidgetConfig.forget(context, id)
    }
}
