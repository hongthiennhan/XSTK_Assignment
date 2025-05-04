1. đọc thông tin file
2. thống kê mô tả (sau phần tiền xử lý dữ liệu) (Chọn Provider làm factor)
	2.1. phương sai, trung vị, 
3. tiền xử lý dữ liệu
	3.1. làm sạch dữ liệu
		3.1.1. Dữ liệu khuyết (Không bị khuyết)
		3.1.2. Dữ liệu ngoại lai
	3.2. làm rõ dữ liệu 
		3.2.1. Sự cách biệt quá lớn -> dùng log
		3.2.2. Dữ liệu liên tục
		3.2.3. Biến phân loại -> lập bảng thống kê số lượng cho từng loại (hàm table)
		3.2.4. hist, boxplot, pairs
		3.2.5. Hướng xử lý dữ liệu (hơi lú, đoạn 10p-17p)

# Thống kê suy diễn
## Kiểm định một mẫu
- Chọn mẫu Latency
- Phân phối tương đối chuẩn
- Chưa biết phương sai tổng thể
- Kiểm định Shapiro
- p-value = 5.944e-07 nhỏ hơn 0.05 rất nhiều -> không tuân theo phân phối chuẩn
-> Mẫu dữ liệu có phân phối tùy ý, mẫu lớn
- Sử dụng t.test() tìm được khoảng ước lượng là [8.593306; 10.124194] với độ tin cậy 95%

## Kiểm định hai mẫu
- Thông thường độ trễ phản hồi (Latency) thấp do tập Training Dataset Size lớn, do mô hình LLM được huấn luyện nhiều hơn nên sẽ ra quyết định nhanh hơn
- Cho rằng Latency thấp là nhỏ hơn giá trị trung bình, tập Training Dataset Size lớn là lớn hơn trung bình
- Bài toán: Liệu tỷ lệ Latency cao với Dataset lớn, có thực sự thấp hơn tỷ lệ Latency thấp có Dataset lớn
- Kiểm định giả thiết
	- H0: Tỷ lệ Dataset cao của Latency cao và Latency thấp là bằng nhau
	- H1: Tỷ lệ Dataset cao của Latency cao, thấp hơn tỷ lệ Dataset cao của Latency thấp
- Kết quả:
	- p-value = 0.03322 < 0.05
	- Khoảng tin cậy -1.000000000 -0.008609752 nằm bên trái so với 0 -> p1 < p2
	-> Với p-value = 0.03322 nhỏ hơn 0.05 và khoảng tin cậy không chứa 0, kết luận bác bỏ H0, Tỷ lệ Dataset cao của Latency cao, thấp hơn tỷ lệ Dataset cao của Latency thấp. Tỷ lệ của nhóm có Latency thấp là 29.5%, tỷ lệ của nhóm có Latency cao là 21.5%.
	Tuy nhiên, do p-value = 0.03322 không nhơ hơn 5% đáng kể nên tỷ lệ chênh lệch không quá lớn.

# Phân tích phương sai
## Bài toán
- Có sự khác biệt có ý nghĩa thống kê về hiệu suất năng lượng trung bình giữa các nhà cung cấp mô hình ngôn ngữ lớn (LLM) không?
## Kiểm tra giả thiết
- Xác định các mẫu có độc lập với nhau hay không.
- Kiểm tra xem hiệu suất năng lượng trung bình giữa các nhà cung cấp LLM có tuân theo phân phối chuẩn hay không.
- Kiểm tra sự tương đồng về phương sai mẫu giữa các nhà cung cấp.
## Tiến hành
- Lấy mẫu với tần suất trên 20 (do số lượng mẫu trên 30 chỉ có hai nhà cung cấp, khó có thể đánh giá được, và số lượng mẫu của dataset không nhiều, nên lấy mẫu có tần suất trên 20)
- Test Shapiro
- Test Levene, thấy p-value = 0.2829 > 0.05 -> Không bác bỏ H0: Phương sai giữa các nhóm là đồng nhất
- Giả thiết không H0: Latency không phụ thuộc vào các nhà cung cấp LLM
- Giả thiết đối H1: Latency phụ thuộc vào các nhà cung cấp LLM
- Chạy ANOVA
	- F-value = 0.186 -> rất nhỏ, cho thấy trung bình giữa các nhóm gần bằng nhau
	- p-value = 0.668 > 0.5 -> không bác bỏ H0 -> Latency không phụ thuộc vào các nhà cung cấp LLM
- Phân tích hậu định
	- Không có cặp nào có sự khác biệt có ý nghĩa thống kê về Latency.
	- Tất cả các đoạn confidence interval (CI) đều cắt trục 0.
	- Điều đó có nghĩa: sự khác biệt trung bình giữa các cặp Provider không đáng kể tại mức ý nghĩa 95%.
	- Dựa vào biểu đồ, ta có thể thấy các mô hình LLM của AWS có xu hướng thấp hơn các nhà phân phối khác
# Hồi quy tuyến tính


# Từ từ tính :)))
4. Phân tích
2.1. Kiểm định giả thuyết thống kê
Trong bài toán này, chúng ta sẽ thực hiện kiểm định giả thuyết thống kê để đánh giá sự khác biệt giữa các mô hình ngôn ngữ lớn (LLM) mà bạn đang phân tích. Mục tiêu là xác định xem có sự khác biệt có ý nghĩa thống kê về hiệu suất giữa các mô hình hay không.

Giả thuyết kiểm định:

Giả thuyết H0 (Null Hypothesis):

Giả thuyết này cho rằng không có sự khác biệt đáng kể về hiệu suất giữa các mô hình LLM.

Ví dụ: "Hiệu suất của các mô hình LLM (được đo bằng độ chính xác hay một chỉ số nào đó) là như nhau."

Giả thuyết H1 (Alternative Hypothesis):

Giả thuyết này phản bác H0, cho rằng có sự khác biệt đáng kể giữa các mô hình.

Ví dụ: "Có ít nhất một mô hình LLM có hiệu suất khác biệt đáng kể so với các mô hình còn lại."

Tiêu chuẩn kiểm định:

Chúng ta sẽ sử dụng kiểm định ANOVA (phân tích phương sai) để so sánh sự khác biệt giữa các nhóm (mô hình LLM).

Miền bác bỏ giả thiết (Wα):

Chúng ta sẽ chọn mức ý nghĩa α = 0.05. Miền bác bỏ là nơi mà xác suất xảy ra giá trị thống kê kiểm định G (tính từ mẫu thực nghiệm) nằm ngoài miền này.

Quy tắc kiểm định:

Nếu giá trị thống kê kiểm định (gqs) rơi vào miền bác bỏ Wα, chúng ta bác bỏ H0 và chấp nhận H1.

Nếu gqs không rơi vào miền bác bỏ, chúng ta không có đủ dữ liệu để bác bỏ H0.

2.2. Cơ sở lý thuyết về phân tích phương sai (ANOVA)
Phân tích phương sai (ANOVA) là một công cụ thống kê giúp xác định sự ảnh hưởng của một yếu tố (ví dụ, mô hình LLM) đến một yếu tố kết quả (ví dụ, độ chính xác của mô hình). Trong trường hợp này, ta sẽ sử dụng ANOVA một yếu tố để so sánh các mô hình LLM.

Các giả định trong ANOVA một yếu tố:

Các tổng thể mô hình LLM có phân phối chuẩn.

Các phương sai của các tổng thể là bằng nhau.

Các mẫu dữ liệu là độc lập.

Giả thuyết cho bài toán phân tích phương sai một nhân tố:

H0: "Hiệu suất của tất cả các mô hình LLM là như nhau."

H1: "Có ít nhất một mô hình LLM có hiệu suất khác biệt."

2.3. Các bước tiến hành phân tích phương sai (ANOVA)
Bước 1: Tính toán các trung bình mẫu

Tính trung bình hiệu suất cho mỗi nhóm mô hình LLM.

Tính trung bình chung của toàn bộ dữ liệu.

Bước 2: Tính tổng các chênh lệch bình phương

SSB (tổng các chênh lệch bình phương giữa các nhóm): Đo lường sự biến thiên giữa các nhóm mô hình.

SSW (tổng các chênh lệch bình phương trong nhóm): Đo lường sự biến thiên trong các nhóm mô hình.

SST (tổng các chênh lệch bình phương tổng thể): Tổng của SSB và SSW.

Bước 3: Tính các phương sai

MSB (phương sai giữa các nhóm): Tính bằng SSB/(k-1), với k là số lượng nhóm (mô hình LLM).

MSW (phương sai trong nhóm): Tính bằng SSW/(N-k), với N là tổng số quan sát.

Bước 4: Tính thống kê kiểm định (F)

F = MSB / MSW, và so với giá trị F từ bảng phân phối F.

Bước 5: Quyết định kiểm định

Nếu F tính được lớn hơn F0.05 từ bảng phân phối F, chúng ta bác bỏ H0 và kết luận rằng ít nhất một mô hình LLM có hiệu suất khác biệt đáng kể.

2.4. Kết luận
Dựa trên kết quả từ kiểm định ANOVA, chúng ta sẽ quyết định:

Nếu F tính được lớn hơn F0.05, bác bỏ H0 và thừa nhận rằng có sự khác biệt về hiệu suất giữa các mô hình.

Nếu F tính được nhỏ hơn F0.05, không bác bỏ H0, nghĩa là không có sự khác biệt đáng kể giữa các mô hình.