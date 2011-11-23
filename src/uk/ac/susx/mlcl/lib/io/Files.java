/*
 * Copyright (c) 2011, MLCL, Sussex University.
 * All rights reserverd.
 */
package uk.ac.susx.mlcl.lib.io;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.FileReader;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.io.OutputStreamWriter;
import java.io.Reader;
import java.nio.channels.Channels;
import java.nio.channels.ReadableByteChannel;
import java.nio.channels.WritableByteChannel;
import java.nio.charset.Charset;
import java.nio.charset.CharsetDecoder;
import java.nio.charset.CharsetEncoder;
import java.nio.charset.CodingErrorAction;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.List;
import java.util.zip.GZIPInputStream;
import java.util.zip.GZIPOutputStream;

/**
 * Static utility class for file manipulation.
 * 
 * @author Simon Wibberley &lt;simon.wibberley@sussex.ac.uk&gt;
 * @author Hamish Morgan &lt;hamish.morgan@sussex.ac.uk&gt;
 */
public final class Files {

    private Files() {
    }

    public static List<String> getFileList(String path, final String suffix) {
        return getFileList(new File(path), suffix, false);
    }

    public static List<String> getFileList(File path, final String suffix) {
        return getFileList(path, suffix, false);
    }

    public static List<String> getFileList(String path, final String suffix,
                                           final boolean includeHidden) {
        return getFileList(new File(path), suffix, includeHidden, false);
    }

    public static List<String> getFileList(File path, final String suffix,
                                           final boolean includeHidden) {
        return getFileList(path, suffix, includeHidden, false);
    }

    public static List<String> getFileList(String path, final String suffix,
                                           final boolean includeHidden,
                                           final boolean recursive) {
        return getFileList(new File(path), suffix, includeHidden, recursive);
    }

    public static List<String> getFileList(File path, final String suffix,
                                           final boolean includeHidden,
                                           final boolean recursive) {
        if (path == null)
            throw new NullPointerException("path is null");
        if (suffix == null)
            throw new NullPointerException("suffix is null");

        if (!path.exists()) {
            throw new IllegalArgumentException("path does not exist: " + path);
        }
        if (!path.isDirectory()) {
            throw new IllegalArgumentException("path is not a directory: " + path);
        }
        if (!path.canRead()) {
            throw new IllegalArgumentException("path is not readable: " + path);
        }

        final ArrayList<String> fileList = new ArrayList<String>();

        final FilenameFilter filter = new FilenameFilter() {

            @Override
            public boolean accept(File dir, String name) {
                if (recursive) {
                    File f = new File(
                            dir.getAbsolutePath() + File.separator + name);
                    if (f.isDirectory()) {

                        List<String> subList = getFileList(
                                f.getAbsoluteFile(), suffix, includeHidden,
                                recursive);

                        for (String file : subList) {
                            String subPath = name + File.separator + file;
                            fileList.add(subPath);
                        }
                    }
                }
                if (includeHidden) {
                    return name.toLowerCase().endsWith(suffix);
                } else {
                    String lc = name.toLowerCase();
                    return lc.endsWith(suffix) && !lc.startsWith(".");
                }

            }

        };

        fileList.addAll(Arrays.asList(path.list(filter)));

        return fileList;
    }

    public static CharSequence getText(String file) throws IOException {
        return getText(new File(file), false, false);
    }

    public static CharSequence getText(File file) throws IOException {
        return getText(file, false, false);
    }

    public static CharSequence getText(
            String file, boolean gzip, boolean incNewline) throws IOException {
        return getText(new File(file), gzip, incNewline);
    }

    public static CharSequence getText(
            File file, boolean gzip, boolean incNewline) throws IOException {
        if (gzip) {
            return getText(new InputStreamReader(
                    new GZIPInputStream(new FileInputStream(file))), incNewline);
        } else {
            return getText(new BufferedReader(new FileReader(file)),
                           incNewline);
        }

    }

    public static CharSequence getText(Reader reader) throws IOException {
        return getText(reader, false);
    }

    public static final int BUFFER_SIZE = 8192;

    public static CharSequence getTextWholeFile(Reader in) throws IOException {
        final StringBuilder strbldr = new StringBuilder();
        try {
            final char[] strbuf = new char[BUFFER_SIZE];
            int read;
            while ((read = in.read(strbuf)) >= 0) {
                strbldr.append(strbuf, 0, read);
            }
        } finally {
            in.close();
        }
        return strbldr;
    }

    public static CharSequence getText(Reader in, boolean incNewline) throws IOException {
        if (incNewline) {
            return getTextWholeFile(in);
        }
        final StringBuilder strbfr = new StringBuilder();
        try {
            final BufferedReader br = (in instanceof BufferedReader)
                                      ? ((BufferedReader) in)
                                      : new BufferedReader(in);
            String tmpStr;
            while ((tmpStr = br.readLine()) != null) {
                strbfr.append(tmpStr);
            }
        } finally {
            in.close();
        }
        return strbfr;
    }

    public static int countLines(File in) throws IOException {
        return countLines(new FileReader(in));
    }

    public static int countLines(InputStream in) throws IOException {
        return countLines(new InputStreamReader(in));
    }

    public static int countLines(Reader in) throws IOException {
        final BufferedReader br = (in instanceof BufferedReader)
                                  ? ((BufferedReader) in)
                                  : new BufferedReader(in);
        int count = 0;
        while (br.readLine() != null) {
            ++count;
        }
        return count;
    }

    public static File createTempDir(String prefix, String suffix,
                                     File directory) throws IOException {
        final File temp = File.createTempFile(prefix, suffix, directory);
        if (!temp.delete() || !temp.mkdir() || !temp.isDirectory())
            throw new IOException("Failed to create temporary directory " + temp);
        return temp;
    }

    public static File createTempDir(String prefix, String suffix) throws IOException {
        return createTempDir(prefix, suffix, null);
    }

    @Deprecated
    public static final File STDIN_FILE = new File("-");

    @Deprecated
    public static final File STDOUT_FILE = new File("-");

    public static final Charset DEFAULT_CHARSET = Charset.forName("UTF-8");// Charset.defaultCharset();

    /*
     * XXX: The following fields are not final because they are changed to 
     * "REPORT" during unit tests. Obviously this is not ideal.
     */
    public static CodingErrorAction MALFORMED_INPUT_ACTION = CodingErrorAction.REPLACE;

    public static CodingErrorAction UNMAPPABLE_CHARACTER_ACTION = CodingErrorAction.REPLACE;

    @Deprecated
    public static boolean isStdin(File file) {
        return file.getName().equals(STDIN_FILE.getName());
    }

    @Deprecated
    public static boolean isStdout(File file) {
        return file.getName().equals(STDOUT_FILE.getName());
    }

    public static boolean isGzip(File file) {
        return file.getName().toLowerCase().endsWith(".gz");
    }

    public static CharsetDecoder decoderFor(Charset charset) {
        return charset.newDecoder().
                onMalformedInput(MALFORMED_INPUT_ACTION).
                onUnmappableCharacter(UNMAPPABLE_CHARACTER_ACTION);
    }

    public static CharsetEncoder encoderFor(Charset charset) {
        return charset.newEncoder().
                onMalformedInput(MALFORMED_INPUT_ACTION).
                onUnmappableCharacter(UNMAPPABLE_CHARACTER_ACTION);
    }

    public static BufferedReader openReader(
            final File file, final Charset charset)
            throws FileNotFoundException, IOException {
        return new BufferedReader(new InputStreamReader(
                openInputStream(file), decoderFor(charset)));
    }

    public static BufferedWriter openWriter(
            final File file, final Charset charset)
            throws FileNotFoundException, IOException {
        return new BufferedWriter(
                new OutputStreamWriter(openOutputStream(file), encoderFor(
                charset)));
    }

    public static ReadableByteChannel openReadableByteChannel(final File file)
            throws FileNotFoundException, IOException, NullPointerException {
        if (file == null) {

            throw new NullPointerException("file is null");

        } else if (isStdin(file)) {
            return Channels.newChannel(System.in);
        } else if (isGzip(file)) {
            return Channels.newChannel(
                    new GZIPInputStream(
                    new FileInputStream(file)));
        } else {
            return new FileInputStream(file).getChannel();
        }
    }

    public static WritableByteChannel openWritableByteChannel(File file)
            throws FileNotFoundException, IOException, NullPointerException {
        if (file == null) {

            throw new NullPointerException("file is null");

        } else if (isStdout(file)) {
            return Channels.newChannel(System.out);
        } else if (isGzip(file)) {
            return Channels.newChannel(
                    new GZIPOutputStream(
                    new FileOutputStream(file)));
        } else {
            return new FileOutputStream(file).getChannel();
        }
    }

    public static InputStream openInputStream(final File file)
            throws FileNotFoundException, IOException {
        if (file == null)
            throw new NullPointerException();
        if (isStdin(file)) {
            return System.in;
        } else if (isGzip(file)) {
            return new GZIPInputStream(
                    new FileInputStream(file));
        } else {
            return new BufferedInputStream(new FileInputStream(file));
        }
    }

    public static OutputStream openOutputStream(File file)
            throws FileNotFoundException, IOException {
        if (file == null)
            throw new NullPointerException();
        if (isStdout(file)) {
            return System.out;
        } else if (isGzip(file)) {
            return new GZIPOutputStream(new FileOutputStream(file));
        } else {
            return new BufferedOutputStream(new FileOutputStream(file));
        }
    }

    public static String fileName(final File file, Object thing) {
        if (file == null || file.getName().equals("-")) {
            return (thing instanceof Readable || thing instanceof InputStream) ? "stdin"
                   : (thing instanceof Appendable || thing instanceof OutputStream) ? "stdout"
                     : "file";
        } else {
            return file.getName();
        }
    }

    public static void readAllLines(File file, Charset charset,
                                    Collection<? super String> lines)
            throws FileNotFoundException, IOException {
        BufferedReader reader = null;
        try {
            reader = openReader(file, charset);
            String line = reader.readLine();
            while (line != null) {
                lines.add(line);
                line = reader.readLine();
            }
        } finally {
            if (reader != null)
                reader.close();
        }
    }

    public static void writeAllLines(File file, Charset charset,
                                     Collection<? extends String> lines)
            throws FileNotFoundException, IOException {

        BufferedWriter writer = null;
        try {
            writer = openWriter(file, charset);
            for (String line : lines) {
                writer.write(line);
                writer.newLine();
            }
        } finally {
            if (writer != null) {
                writer.flush();
                writer.close();
            }
        }
    }

    public static void readAll(File file, Charset charset, StringBuilder dst)
            throws FileNotFoundException, IOException {
        BufferedReader reader = null;
        try {
            reader = openReader(file, charset);
            char[] buf = new char[10000];
            int len = 0;
            while ((len = reader.read(buf)) != -1) {
                dst.append(buf, 0, len);
            }
        } finally {
            if (reader != null)
                reader.close();
        }
    }

    public static void writeAll(File file, Charset charset, CharSequence src)
            throws FileNotFoundException, IOException {
        BufferedWriter writer = null;
        try {
            writer = openWriter(file, charset);
            writer.append(src);
        } finally {
            if (writer != null) {
                writer.flush();
                writer.close();
            }
        }
    }

}
