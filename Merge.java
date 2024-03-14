import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.*;

public class Merge {

    private static final int MAX_LINES = 10000;
    private static Map<String, Integer> map;

    public static void main(String[] args) throws IOException {
        System.out.println("Читання даних з файлу...");
        readFile("input.txt");
        calculateAverageValues();
    }

    public static void readFile(String filename) throws IOException {
        BufferedReader br = new BufferedReader(new FileReader(filename));
        map = new HashMap<>();
        String line;
        int lineCount = 0;
        while ((line = br.readLine()) != null && lineCount < MAX_LINES) {
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
            lineCount++;
        }
        br.close();
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

        int index = 0;
        double[] averageValues = new double[map.size()];
        String[] keys = new String[map.size()];
        for (Map.Entry<String, Integer> entry : sumValues.entrySet()) {
            String key = entry.getKey();
            int sum = entry.getValue();
            int count = countValues.get(key);
            averageValues[index] = (double) sum / count;
            keys[index++] = key;
        }

        mergeSort(averageValues, keys, 0, averageValues.length - 1);

        for (int i = averageValues.length - 1; i >= 0; i--) {
            System.out.println(keys[i]);
        }
        for (int j = 0; j < averageValues.length; j++) {
            System.out.println("Середнє значення " + (j + 1) + ": " + averageValues[j]);
        }
    }

    private static void mergeSort(double[] arr, String[] keys, int left, int right) {
        if (left < right) {
            int mid = (left + right) / 2;
            mergeSort(arr, keys, left, mid);
            mergeSort(arr, keys, mid + 1, right);
            merge(arr, keys, left, mid, right);
        }
    }

    private static void merge(double[] arr, String[] keys, int left, int mid, int right) {
        int n1 = mid - left + 1;
        int n2 = right - mid;

        double[] L = new double[n1];
        String[] LKeys = new String[n1];
        for (int i = 0; i < n1; ++i) {
            L[i] = arr[left + i];
            LKeys[i] = keys[left + i];
        }

        double[] R = new double[n2];
        String[] RKeys = new String[n2];
        for (int j = 0; j < n2; ++j) {
            R[j] = arr[mid + 1 + j];
            RKeys[j] = keys[mid + 1 + j];
        }

        int i = 0, j = 0;
        int k = left;
        while (i < n1 && j < n2) {
            if (L[i] >= R[j]) {
                arr[k] = L[i];
                keys[k] = LKeys[i];
                i++;
            } else {
                arr[k] = R[j];
                keys[k] = RKeys[j];
                j++;
            }
            k++;
        }

        while (i < n1) {
            arr[k] = L[i];
            keys[k] = LKeys[i];
            i++;
            k++;
        }

        while (j < n2) {
            arr[k] = R[j];
            keys[k] = RKeys[j];
            j++;
            k++;
        }
    }
}
