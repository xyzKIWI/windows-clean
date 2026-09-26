# windows-clean — Windows 暫存與快取清理

一個 `.bat` 批次檔，清理 Windows 暫存檔與各種快取。純文字檔，可以先用記事本打開檢查內容再執行。

## 用法

1. 到 [Releases](https://github.com/xyzKIWI/windows-clean/releases/latest) 下載 `Clean.bat`
2. **雙擊執行＝一般模式**：只清目前使用者自己的暫存與快取，不需要系統管理員權限
3. **按右鍵「以系統管理員身分執行」＝完整模式**：額外清理系統層
4. 完成後按任意鍵關閉視窗

## 清理項目

| 項目 | 一般模式 | 完整模式 |
|---|:-:|:-:|
| 使用者暫存（`%TEMP%`） | ✓ | ✓ |
| 使用者當機傾印、錯誤報告 | ✓ | ✓ |
| 網路暫存（INetCache）、Edge／Chrome 預設設定檔的網頁快取 | ✓ | ✓ |
| 檔案總管縮圖與圖示快取 | ✓ | ✓ |
| 資源回收筒（目前使用者） | ✓ | ✓ |
| DNS 解析快取 | ✓ | ✓ |
| Windows Update 下載快取（會暫停 wuauserv／bits／cryptsvc，清完自動開回） | | ✓ |
| `C:\Windows\Temp`、Prefetch | | ✓ |
| 系統當機傾印、系統錯誤報告、`C:\Windows` 底下的 `.log` 檔 | | ✓ |
| 所有磁碟的資源回收筒（全部使用者） | | ✓ |

## 注意

- 檔案是 Big5（cp950）編碼、CRLF 換行；修改時請用不會改編碼的編輯器，否則中文會變亂碼（`.gitattributes` 已設 binary 保護）
- 共用電腦請依單位資訊安全政策使用
- 以 MIT 授權按現狀提供，使用風險自負
