package com.example.sms_app

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.Bundle
import android.telephony.SmsMessage
import android.util.Log

class SmsReceiver : BroadcastReceiver() {

    // Replace this with your device number or expected sender ID
    private val allowedSender = "YOUR_DEVICE_NUMBER_OR_ID"

    override fun onReceive(context: Context?, intent: Intent?) {
        val bundle: Bundle? = intent?.extras
        val pdus = bundle?.get("pdus") as? Array<*>

        pdus?.forEach { pdu ->
            val format = bundle.getString("format")
            val message = SmsMessage.createFromPdu(pdu as ByteArray, format)
            val sender = message.displayOriginatingAddress
            val body = message.messageBody

            if (sender.contains(allowedSender)) {
                Log.d("G-Alert", "Received from G-Alert device: $body")

                // You can pass this to Flutter or display it
                val filteredIntent = Intent("com.example.sms_app.DEVICE_MESSAGE")
                filteredIntent.putExtra("message", body)
                context?.sendBroadcast(filteredIntent)
            }
        }
    }
}
