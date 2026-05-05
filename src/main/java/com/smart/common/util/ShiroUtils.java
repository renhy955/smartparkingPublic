package com.smart.common.util;

import com.smart.module.sys.entity.SysUser;
import org.apache.shiro.SecurityUtils;
import org.apache.shiro.subject.Subject;

public class ShiroUtils {

    public static Subject getSubject() {
        return SecurityUtils.getSubject();
    }

    public static Object getPrincipal() {
        return getSubject().getPrincipal();
    }

    public static SysUser getUserEntity() {
        Object principal = getPrincipal();
        if (principal instanceof SysUser) {
            return (SysUser) principal;
        }
        return null;
    }

    public static Long getUserId() {
        SysUser user = getUserEntity();
        if (user != null) {
            return user.getUserId();
        }
        return null;
    }

    public static void logout() {
        getSubject().logout();
    }
}