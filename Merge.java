import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.HashMap;
import java.util.Map;
import java.util.StringTokenizer;

public class Merge {

    private static final int MAX_LINES = 10000;
    private static Map<String, Integer> map;

    public static void main(String[] args) throws IOException {
        System.out.println("Вводьте: " + "\n" + "Коли захочете припинити введення, то введіть: end");
        getValue();
    }

    public static void getValue() throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        map = new HashMap<>();
        for (int i = 0; i < MAX_LINES; i++) {
            String line = br.readLine();
            if (line.equals("end")) {
                break;
            }
            if (line.isEmpty()) {
                System.err.println("Ви ввели пустий рядок");
                continue;
            }
            StringTokenizer st = new StringTokenizer(line, " ");
            String key = st.nextToken();
            if (key.length() > 15) {
                System.err.println("Ключ має бути не більше 16 символів");
                continue;
            }
            if (key.isEmpty()) {
                System.err.println("Ключ не може бути пустим");
                continue;
            }

            String value = st.nextToken();
            int val;
            try {
                val = Integer.parseInt(value);
            } catch (NumberFormatException e) {
                System.err.println("Невірний формат значення");
                continue;
            }
            if (val > 10000 || val < -10000) {
                System.err.println("Значення має бути в межах від -10000 до 1000");
                continue;
            }
            map.put(key, val);
        }
        System.out.println(map);
        calculateAverageValues();
    }

    public static void calculateAverageValues() {
        Map<String, Integer> sumValues = new HashMap<>();
        Map<String, Integer> countValues = new HashMap<>();

        for (Map.Entry<String, Integer> entry : map.entrySet()) {
            String key = entry.getKey();
            int value = entry.getValue();

            sumValues.put(key, sumValues.getOrDefault(key, 0) + value);
            countValues.put(key, countValues.getOrDefault(key, 0) + 1);
        }

        int[] averageValues = new int[map.size()];
        int index = 0;
        for (Map.Entry<String, Integer> entry : sumValues.entrySet()) {
            String key = entry.getKey();
            int sum = entry.getValue();
            int count = countValues.get(key);
            averageValues[index++] = sum / count;
        }

        for (int j = 0; j < averageValues.length; j++) {
            System.out.println("Середнє значення " + (j + 1) + ": " + averageValues[j]);
        }
    }
}