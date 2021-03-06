# Gathering information using Windows Command Line

```
Windows cung cấp một số tiện ích để thu thập thông tin như: nslookup, ping, tracert...
```
1. ping
```
Để kiểm tra maximum frame size chạy lệnh:
ping <domain> -f -l <size bytes>
để tìm ra được maximum frame size 
Khi kết quả trả về là fragmented but DF set thì tức là các gói dữ liệu gửi đi đề không thể nhận được
>>> Giải pháp lúc này mình set MTU là nhỏ hơn <size bytes> trước đó chạy test lại
-c Đếm. Gửi gói tin với số lượng định trước và dừng lại. Một cách dừng khác là gõ [ctrl]-C. Tùy chọn này thuận tiện cho tập lệnh thường xuyên kiểm tra biểu hiện của mạng.
-t Ping cho đến khi được dừng ([ctrl]-C).
-w Thời gian chờ. Số mili giây chờ phản hồi trước khi hiện thông điệp thông báo hết thời gian chờ hoặc gói tin đã bị thất lạc. Thời gian chờ dài hơn được sử dụng để xác định vấn đề về độ trễ. ping -w 10000. Thường thì nó chỉ hữu ích khi được vận hành thông qua mạng di động, vệ tinh hoặc những mạng có độ trễ cao khác.
-n Chỉ hiển thị kết quả bằng số. Tùy chọn này được dùng để tránh liên lạc với một máy chủ tên miền.
-p Khuôn mẫu. Khuôn mẫu là một chuỗi các ký số thập lục phân được thêm vào phần cuối của gói tin. Tùy chọn này hiếm khi hữu dụng trong trường hợp có nghi ngờ về vấn đề liên quan đến việc phụ thuộc vào dữ liệu.
-R Dùng Bản ghi Định tuyến của IP để quyết định tuyến đi của gói tin ping. Máy chủ mục tiêu có thể sẽ không cung cấp thông tin này.
-r Bỏ qua bảng định tuyến. Tùy chọn này được sử dụng khi nghi ngờ có vấn đề về định tuyến và lệnh ping không thể tìm được tuyến đến máy chủ mục tiêu. Tùy chọn này chỉ có tác dụng với máy chủ liên kết trực tiếp được mà không cần sử dụng bất kỳ bộ định tuyến nào.
-s Kích cỡ gói tin. Thay đổi kích cỡ của các gói tin. Kiểm tra những gói tin rất lớn bắt buộc phải bị phân mảnh.
-V Kết quả dài. Hiển thị gói tin ICMP phụ thêm với những thông tin vô cùng chi tiết.
-f Làm ngập. Gửi gói tin nhanh nhất có thể. Tùy chọn này được dùng để kiểm tra hiệu suất của mạng dưới áp lực cao và nên tránh.
-l Tải lại. Gửi gói tin tải lại càng sớm càng tốt, sau đó chuyển sang chế độ thông thường. Tùy chọn này tốt cho việc tìm hiểu liệu bộ định tuyến của bạn có thể xử lý nhanh được bao nhiêu gói tin và do đó, tốt cho việc xác định vấn đề chỉ xuất hiện với kích thước cửa sổ TCP lớn.
-? Hỗ trợ. Tùy chọn này được dùng để xem toàn bộ danh sách những tùy chọn và cách sử dụng cú pháp trong Ping.
- **Thông tin trường TTL(Time to Live): ** 
TTL=64 = *nix - the hop count so if your getting 61 then there are 3 hops and its a *nix device. Most likely Linux.

TTL=128 = Windows - again if the TTL is 127 then the hop is 1 and its a Windows box.

TTL=254 = Solaris/AIX - again if the TTL is 250 then the hop count is 4 and its a Solaris box.

Tham khao: https://subinsb.com/default-device-ttl-values/

```
2. nslookup

