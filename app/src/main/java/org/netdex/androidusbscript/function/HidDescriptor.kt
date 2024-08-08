package org.netdex.androidusbscript.function

import org.netdex.androidusbscript.configfs.function.HidParameters
import org.netdex.androidusbscript.util.Util
/**
 * Descriptors for supported HID devices
 */
enum class HidDescriptor(val parameters: HidParameters) {
    KEYBOARD(
        HidParameters(
            protocol = 1,
            subclass = 1,
            reportLength = 8,
            Util.byteArrayOfInts(
                0x05, 0x01,  /* USAGE_PAGE (GENERIC DESKTOP)	            */
                0x09, 0x06,  /* USAGE (KEYBOARD)                            */
                0xa1, 0x01,  /* COLLECTION (APPLICATION)                    */
                0x05, 0x07,  /*   USAGE_PAGE (KEYBOARD)                     */
                0x19, 0xe0,  /*   USAGE_MINIMUM (KEYBOARD LEFTCONTROL)      */
                0x29, 0xe7,  /*   USAGE_MAXIMUM (KEYBOARD RIGHT GUI)        */
                0x15, 0x00,  /*   LOGICAL_MINIMUM (0)                       */
                0x25, 0x01,  /*   LOGICAL_MAXIMUM (1)                       */
                0x75, 0x01,  /*   REPORT_SIZE (1)                           */
                0x95, 0x08,  /*   REPORT_COUNT (8)                          */
                0x81, 0x02,  /*   INPUT (DATA,VAR,ABS)                      */
                0x95, 0x01,  /*   REPORT_COUNT (1)                          */
                0x75, 0x08,  /*   REPORT_SIZE (8)                           */
                0x81, 0x03,  /*   INPUT (CNST,VAR,ABS)                      */
                0x95, 0x05,  /*   REPORT_COUNT (5)                          */
                0x75, 0x01,  /*   REPORT_SIZE (1)                           */
                0x05, 0x08,  /*   USAGE_PAGE (LEDS)                         */
                0x19, 0x01,  /*   USAGE_MINIMUM (NUM LOCK)                  */
                0x29, 0x05,  /*   USAGE_MAXIMUM (KANA)                      */
                0x91, 0x02,  /*   OUTPUT (DATA,VAR,ABS)                     */
                0x95, 0x01,  /*   REPORT_COUNT (1)                          */
                0x75, 0x03,  /*   REPORT_SIZE (3)                           */
                0x91, 0x03,  /*   OUTPUT (CNST,VAR,ABS)                     */
                0x95, 0x06,  /*   REPORT_COUNT (6)                          */
                0x75, 0x08,  /*   REPORT_SIZE (8)                           */
                0x15, 0x00,  /*   LOGICAL_MINIMUM (0)                       */
                0x25, 0x65,  /*   LOGICAL_MAXIMUM (101)                     */
                0x05, 0x07,  /*   USAGE_PAGE (KEYBOARD)                     */
                0x19, 0x00,  /*   USAGE_MINIMUM (RESERVED)                  */
                0x29, 0x65,  /*   USAGE_MAXIMUM (KEYBOARD APPLICATION)      */
                0x81, 0x00,  /*   INPUT (DATA,ARY,ABS)                      */
                0xc0                  /* END_COLLECTION                              */
            )
        )
    ),
    MOUSE(
        HidParameters(
            protocol = 2,
            subclass = 1,
            reportLength = 4,
            Util.byteArrayOfInts(
                0X05, 0X01,  /* USAGE PAGE (GENERIC DESKTOP CONTROLs)       */
                0X09, 0X02,  /* USAGE (MOUSE)                               */
                0XA1, 0X01,  /* COLLECTION (APPLICATION)                    */
                0X09, 0X01,  /*   USAGE (POINTER)                           */
                0XA1, 0X00,  /*   COLLECTION (PHYSICAL)                     */
                0X05, 0X09,  /*     USAGE PAGE (BUTTON)                     */
                0X19, 0X01,  /*     USAGE MINIMUM (1)                       */
                0X29, 0X05,  /*     USAGE MAXIMUM (5)                       */
                0X15, 0X00,  /*     LOGICAL MINIMUM (1)                     */
                0X25, 0X01,  /*     LOGICAL MAXIMUM (1)                     */
                0X95, 0X05,  /*     REPORT COUNT (5)                        */
                0X75, 0X01,  /*     REPORT SIZE (1)                         */
                0X81, 0X02,  /*     INPUT (DATA,VARIABLE,ABSOLUTE,BITFIELD) */
                0X95, 0X01,  /*     REPORT COUNT(1)                         */
                0X75, 0X03,  /*     REPORT SIZE(3)                          */
                0X81, 0X01,  /*     INPUT (CONSTANT,ARRAY,ABSOLUTE,BITFIELD)*/
                0X05, 0X01,  /*     USAGE PAGE (GENERIC DESKTOP CONTROLS)   */
                0X09, 0X30,  /*     USAGE (X)                               */
                0X09, 0X31,  /*     USAGE (Y)                               */
                0X09, 0X38,  /*     USAGE (WHEEL)                           */
                0X15, 0X81,  /*     LOGICAL MINIMUM (-127)                  */
                0X25, 0X7F,  /*     LOGICAL MAXIMUM (127)                   */
                0X75, 0X08,  /*     REPORT SIZE (8)                         */
                0X95, 0X03,  /*     REPORT COUNT (3)                        */
                0X81, 0X06,  /*     INPUT (DATA,VARIABLE,RELATIVE,BITFIELD) */
                0XC0,                 /*   END COLLECTION                            */
                0XC0                  /* END COLLECTION                              */
            )
        )
    )
}
