package kz.rvssvl.cbsf

import com.getcapacitor.JSObject
import com.getcapacitor.Plugin

open class CustomPlugin: Plugin() {

    public fun emit(eventName: String, stringToEmit: String) {
        val ret = JSObject()
        ret.put("value", stringToEmit)
        super.notifyListeners(eventName, ret)
    }
}