package org.netdex.hidfuzzer.task;

import org.luaj.vm2.Globals;
import org.luaj.vm2.LuaError;
import org.luaj.vm2.LuaValue;
import org.luaj.vm2.lib.jse.JsePlatform;
import org.netdex.hidfuzzer.configfs.UsbGadget;
import org.netdex.hidfuzzer.lua.LuaHIDBinding;
import org.netdex.hidfuzzer.util.Command;

import eu.chainfire.libsuperuser.Shell;

/**
 * Created by netdex on 1/16/2017.
 */

public class LuaHIDTask implements Runnable {

    private String name_;
    private String src_;
    private AsyncIOBridge aio_;

    private LuaValue luaChunk_;
    private Thread activeThread_;

    public LuaHIDTask(String name, String src, AsyncIOBridge dialogIO) {
        this.name_ = name;
        this.src_ = src;
        this.aio_ = dialogIO;
    }

    @Override
    public void run() {
        activeThread_ = Thread.currentThread();

        aio_.onLogClear();

        Shell.Threaded su = null;

        try {
            su = Shell.Pool.SU.get();

            UsbGadget usbGadget;
            if (Command.pathExists(su, "/config")) {
                usbGadget = new UsbGadget(UsbGadget.Parameters.DEFAULT, "hidfuzzer", "/config");
            } else {
                aio_.onLogMessage("No method exists for accessing hid gadget");
                return;
            }

            try {
                aio_.onLogMessage("<b>-- Started <i>" + name_ + "</i></b>");

                try {
                    Globals globals = JsePlatform.standardGlobals();
                    LuaHIDBinding luaHIDBinding = new LuaHIDBinding(globals, su, usbGadget, aio_);
                    luaChunk_ = globals.load(src_);
                    luaChunk_.call();
                } catch (LuaError e) {
                    if (!(e.getCause() instanceof InterruptedException)) {
                        e.printStackTrace();
                        aio_.onLogMessage("<b>LuaError:</b> " +
                                e.getMessage().replace("\n", "<br>"));
                    }
                }
            } finally {
                aio_.onLogMessage("<b>-- Ended <i>" + name_ + "</i></b>");

                if (usbGadget.isBound(su)) {
                    usbGadget.unbind(su);
                    usbGadget.remove(su);
                }
            }
        } catch (Shell.ShellDiedException e) {
            if (su == null) {
                aio_.onLogMessage("<b>Could not obtain superuser privileges!</b>");
            } else {
                aio_.onLogMessage("<b>SU shell has unexpectedly died!</b>");
            }
        } finally {
            if (su != null) {
                su.close();
            }
            aio_.onSignal(AsyncIOBridge.Signal.DONE);
        }
    }

    public void interrupt() {
        activeThread_.interrupt();
    }
}