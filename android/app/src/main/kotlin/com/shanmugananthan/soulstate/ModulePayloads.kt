package com.shanmugananthan.soulstate

import android.content.Context
import org.json.JSONObject

object DashboardPayload {
    private const val PREFS = "HomeWidgetPreferences"
    private const val KEY = "dashboard_data"

    fun raw(context: Context): JSONObject? = try {
        val json = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
        if (json.isNullOrEmpty()) null else JSONObject(json)
    } catch (_: Exception) {
        null
    }
}

object MoneyPayload {
    private const val PREFS = "HomeWidgetPreferences"
    private const val KEY = "money_data"

    fun raw(context: Context): JSONObject? = try {
        val json = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
        if (json.isNullOrEmpty()) null else JSONObject(json)
    } catch (_: Exception) {
        null
    }
}

object MealsPayload {
    private const val PREFS = "HomeWidgetPreferences"
    private const val KEY = "meals_data"

    fun raw(context: Context): JSONObject? = try {
        val json = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).getString(KEY, null)
        if (json.isNullOrEmpty()) null else JSONObject(json)
    } catch (_: Exception) {
        null
    }
}
