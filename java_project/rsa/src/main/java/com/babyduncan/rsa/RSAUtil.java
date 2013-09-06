package com.babyduncan.rsa;

/**
 * User: guohaozhao (guohaozhao@sohu-inc.com)
 * Date: 13-9-5 17:48
 */

import org.apache.commons.codec.binary.Base64;

import javax.crypto.BadPaddingException;
import javax.crypto.Cipher;
import javax.crypto.IllegalBlockSizeException;
import javax.crypto.NoSuchPaddingException;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.security.*;
import java.security.spec.EncodedKeySpec;
import java.security.spec.PKCS8EncodedKeySpec;

public class RSAUtil {

    private static PrivateKey privateKey;

    static {
        try {
            InputStream in = (RSAUtil.class.getClassLoader().getResourceAsStream("private_key.der"));
            ByteArrayOutputStream bout = new ByteArrayOutputStream();
            byte[] temp = new byte[1024];
            int count = 0;
            while ((count = in.read(temp)) != -1) {
                bout.write(temp, 0, count);
                temp = new byte[1024];
            }
            in.close();
            KeyFactory keyFactory = KeyFactory.getInstance("RSA");
            EncodedKeySpec privateKeySpec = new PKCS8EncodedKeySpec(bout.toByteArray());
            privateKey = keyFactory.generatePrivate(privateKeySpec);

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("RSA encoder Exception");
        }
    }

    public static String decodeText(String sec) throws NoSuchAlgorithmException, NoSuchPaddingException, IllegalBlockSizeException, BadPaddingException, InvalidKeyException, NoSuchProviderException {
        Cipher cipher = Cipher.getInstance("RSA/ECB/PKCS1PADDING");
        cipher.init(Cipher.DECRYPT_MODE, privateKey);
        byte[] base64 = Base64.decodeBase64(sec.getBytes());
        byte[] deBytes = cipher.doFinal(base64);
        return new String(deBytes);

    }

    public static void main(String[] args) throws Exception {
        System.out.println(RSAUtil.decodeText("o0Rzny0LgGxkg6bnO4oTacgRgcBNb0sSTIuwx0J1mJeKhaL85B00SUbtP/HSIzA1aKa5NAqVDDB8xIJEgwNp4X2lb1W3wT/xHfjmfc7oVHH31t8RfpfvCa0nazDYLsYv/iQ6NZXozO9oXrQMjA20THu2wwSkteGX7HfSjW6aQTo="));
    }

}
