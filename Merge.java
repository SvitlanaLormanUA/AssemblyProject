import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

public class Merge {

    private static final int MAX_LINES = 10000;

    public static void main(String[] args) throws IOException {
        System.out.println("Вводьте: ");
        getValue();
    }
    public static void getValue() throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        Map<String, Integer> map = new HashMap<>();
        for (int i = 0; i < MAX_LINES; i++) {
            String line = br.readLine();
            if (line.equals("exit")) {
                break;
            }
            StringTokenizer st = new StringTokenizer(line, " ");
            String key = st.nextToken();
            if (key.length() > 16) {
                System.err.println("Ключ має бути не більше 16 символів");
            }
            String value = st.nextToken();
            map.put(key, Integer.valueOf(value));
        }
        System.out.println(map);

    }
}
