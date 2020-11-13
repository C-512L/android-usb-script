package org.netdex.hidfuzzer.hid;

import java.util.Arrays;
import java.util.concurrent.CountDownLatch;

import org.netdex.hidfuzzer.util.Command;
import eu.chainfire.libsuperuser.Shell;

/**
 * Native communication with HID devices
 * <p>
 * Created by netdex on 1/15/2017.
 */

public class HID {
    private static final byte[] mouse_buf = new byte[4];
    private static final byte[] keyboard_buf = new byte[8];

    /**
     * A        B        C        D
     * XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX
     * <p>
     * A: Mouse button mask
     * B: Mouse X-offset
     * C: Mouse Y-offset
     * D: Mouse wheel offset
     *
     * @param sh     SUExtensions shell
     * @param dev    Mouse device (/dev/hidg1)
     * @param offset HID mouse bytes
     * @return error code
     */
    public static int hid_mouse(Shell.Interactive sh, String dev, byte... offset) {
        throw new UnsupportedOperationException("mouse descriptor not implemented"); // TODO
        /*
        if (offset.length > 4)
            throw new IllegalArgumentException("Your mouse can only move in two dimensions");
        Arrays.fill(mouse_buf, (byte) 0);
        System.arraycopy(offset, 0, mouse_buf, 0, offset.length);
        return write_bytes(sh, dev, mouse_buf);*/
    }

    /**
     * A        B        C        D        E        F        G        H
     * XXXXXXXX 00000000 XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX XXXXXXXX
     * <p>
     * A: K modifier mask
     * B: Reserved
     * C: K 1; D: K 2; E: K 3; F: K 4; G: K 5; H: K 6;
     *
     * @param sh   SUExtensions shell
     * @param dev  KB device (/dev/hidg0)
     * @param keys HID keyboard bytes
     * @return error code
     */
    public static int hid_keyboard(Shell.Interactive sh, String dev, byte... keys) {
        if (keys.length > 7)
            throw new IllegalArgumentException("Cannot send more than 6 keys");
        Arrays.fill(keyboard_buf, (byte) 0);
        if (keys.length > 0) keyboard_buf[0] = keys[0];
        if (keys.length > 1) System.arraycopy(keys, 1, keyboard_buf, 2, keys.length - 1);
        return write_bytes(sh, dev, keyboard_buf);
    }

    // TODO I'm pretty sure this code could be more efficient
    private static final int[] mErr = new int[1];

    /**
     * Writes bytes to a file with "echo -n -e [binary string] > file"
     *
     * @param sh  Interactive shell to send echo command
     * @param dev File to write to
     * @param arr Bytes to write
     * @return error code
     */
    private static int write_bytes(Shell.Interactive sh, String dev, byte[] arr) {
        String bt = Command.escapeBytes(arr);
        mErr[0] = -1;
        try {
            // run echo command to write to device as root
            final CountDownLatch latch = new CountDownLatch(1);
            String c = "echo -n -e \"" + bt + "\" > " + dev;
//            Log.d("A", c);
            sh.addCommand(c, 0, new Shell.OnCommandLineListener() {
                @Override
                public void onSTDOUT(String line) {

                }

                @Override
                public void onSTDERR(String line) {

                }

                @Override
                public void onCommandResult(int commandCode, int exitCode) {
                    mErr[0] = exitCode;
                    latch.countDown();
                }
            });
            latch.await();
        } catch (InterruptedException ignored) {
        } catch (Exception e) {
            e.printStackTrace();
        }
        return mErr[0];
    }




}
