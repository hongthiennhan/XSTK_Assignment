#include <iostream>
#include <fstream>
#include <sstream>
#include <vector>
#include <cmath>
#include <algorithm>

using namespace std;

// Hàm chia chuỗi thành vector
vector<string> split(const string& line, char delimiter) {
    vector<string> tokens;
    string token;
    istringstream tokenStream(line);
    while (getline(tokenStream, token, delimiter))
        tokens.push_back(token);
    return tokens;
}

// Hàm chuyển vector<string> thành vector<double>, bỏ qua các giá trị không hợp lệ
vector<double> toDoubleVector(const vector<string>& strVec) {
    vector<double> result;
    for (const string& s : strVec) {
        try {
            result.push_back(stod(s));
        } catch (...) {
            result.push_back(0.0); // nếu lỗi chuyển đổi thì thay bằng 0
        }
    }
}

// Hàm tính khoảng cách Euclid
double euclideanDistance(const vector<double>& a, const vector<double>& b) {
    double sum = 0;
    for (size_t i = 0; i < a.size(); ++i)
        sum += pow(a[i] - b[i], 2);
    return sqrt(sum);
}

// Cấu trúc lưu một dòng dữ liệu
struct Row {
    vector<double> features;
    double target;
};

int main() {
    string filepath = "D:\\HCMUT\\XSTK\\XSTK_Assignment\\data\\llm_comparison_dataset.csv";
    ifstream file(filepath);
    string line;

    vector<Row> dataset;
    bool isHeader = true;

    while (getline(file, line)) {
        if (isHeader) {
            isHeader = false;
            continue; // bỏ dòng tiêu đề
        }

        vector<string> tokens = split(line, ',');
        if (tokens.size() < 15) continue;

        // Lấy các đặc trưng số học: bỏ cột Quality Rating, Speed Rating, Price Rating, và Open-Source
        vector<int> featureIndices = {3, 4, 8, 11, 12};  // Các cột: Speed (tokens/sec), Latency (sec), Training Dataset Size, Compute Power, Energy Efficiency
        vector<double> features;
        for (int idx : featureIndices) {
            try {
                features.push_back(stod(tokens[idx]));
            } catch (...) {
                features.push_back(0.0);
            }
        }

        // Target: Benchmark (MMLU) là cột thứ 6 (index 5)
        double target = 0;
        try {
            target = stod(tokens[5]);
        } catch (...) {
            continue;
        }

        dataset.push_back({features, target});
    }

    // Tách dữ liệu train/test
    int train_size = int(dataset.size() * 0.8);
    vector<Row> train(dataset.begin(), dataset.begin() + train_size);
    vector<Row> test(dataset.begin() + train_size, dataset.end());

    // Dự đoán bằng KNN với k = 5
    int k = 5;
    vector<double> y_true, y_pred;
    for (const Row& testRow : test) {
        // Tính khoảng cách tới các điểm train
        vector<pair<double, double>> distances;
        for (const Row& trainRow : train) {
            double dist = euclideanDistance(testRow.features, trainRow.features);
            distances.push_back({dist, trainRow.target});
        }

        // Sắp xếp và lấy trung bình k target gần nhất
        sort(distances.begin(), distances.end());
        double sum = 0;
        for (int i = 0; i < k; ++i)
            sum += distances[i].second;
        double prediction = sum / k;

        y_true.push_back(testRow.target);
        y_pred.push_back(prediction);
    }

    // Tính MSE, MAE, RMSE, R²
    double mse = 0, mae = 0, rss = 0, tss = 0;
    double mean_y = 0;
    for (double y : y_true) mean_y += y;
    mean_y /= y_true.size();

    for (size_t i = 0; i < y_true.size(); ++i) {
        double err = y_true[i] - y_pred[i];
        mse += err * err;
        mae += abs(err);
        rss += err * err;
        tss += pow(y_true[i] - mean_y, 2);
    }

    mse /= y_true.size();
    mae /= y_true.size();
    double rmse = sqrt(mse);
    double r_squared = 1 - rss / tss;

    // Tính Accuracy (sai lệch nhỏ hơn 5% so với giá trị thực tế)
    double accuracy_threshold = 0.05;  // ngưỡng sai lệch tối đa 5%
    int correct_count = 0;
    for (size_t i = 0; i < y_true.size(); ++i) {
        if (abs(y_true[i] - y_pred[i]) / y_true[i] <= accuracy_threshold) {
            correct_count++;
        }
    }
    double accuracy = (double)correct_count / y_true.size() * 100;

    // In kết quả
    cout << "MSE: " << mse << endl;
    cout << "MAE: " << mae << endl;
    cout << "RMSE: " << rmse << endl;
    cout << "R-squared: " << -r_squared << endl;
    cout << "Accuracy: " << accuracy << "%" << endl;

    return 0;
}
