import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

public class Merge {

    private static final int MAX_LINES = 10000;

    public static void main(String[] args) throws IOException {
        BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));

        Map<String, Integer> data = new HashMap<>();
        String line;
        int lineCount = 0;
        while ((line = reader.readLine()) != null && lineCount < MAX_LINES) {
            lineCount++;

            StringTokenizer tokenizer = new StringTokenizer(line);
            if (tokenizer.countTokens() != 2) {
                System.err.println("Invalid line: " + line);
                continue;
            }

            String key = tokenizer.nextToken();
            if (key.length() > 16) {
                System.err.println("Invalid key length: " + key);
                continue;
            }

            String value = tokenizer.nextToken();
            int val;
            try {
                val = Integer.parseInt(value);
            } catch (NumberFormatException e) {
                System.err.println("Invalid value: " + value);
                continue;
            }

            if (val < -10000 || val > 10000) {
                System.err.println("Value out of range: " + value);
                continue;
            }

            data.put(key, val);
        }

        // Вивід результату
        for (Map.Entry<String, Integer> entry : data.entrySet()) {
            System.out.println(entry.getKey() + " " + entry.getValue());
        }
    }
}
