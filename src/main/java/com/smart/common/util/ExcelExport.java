package com.smart.common.util;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URLEncoder;
import java.util.List;
import java.util.Map;

public class ExcelExport {

    public static final int CELL_ALIGN_LEFT = 0;

    private File templateFile;
    private int sheetIndex;

    public ExcelExport(File templateFile, int sheetIndex) {
        this.templateFile = templateFile;
        this.sheetIndex = sheetIndex;
    }

    public ExcelExport setDataList(List<Map<String, Object>> list, Map<String, Integer> dataMap, boolean flag, String sheetName) {
        return this;
    }

    public void writeTemplate(HttpServletResponse response, HttpServletRequest request, String fileName) throws IOException {
        response.setContentType("application/vnd.ms-excel");
        response.setHeader("Content-Disposition", "attachment; filename=" + URLEncoder.encode(fileName, "UTF-8"));
        OutputStream out = response.getOutputStream();
        out.write(new byte[0]);
        out.flush();
        out.close();
    }
}