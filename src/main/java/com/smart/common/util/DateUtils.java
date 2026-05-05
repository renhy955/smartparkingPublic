package com.smart.common.util;

import java.sql.Timestamp;

public class DateUtils {

    public static Timestamp getTimestamp() {
        return new Timestamp(System.currentTimeMillis());
    }
}