# Solutions

- **TH:** เนื่องจากผมไม่เก่งภาษาอังกฤษนะครับ จะเขียนตอบเป็นภาษาไทยแทนนะครับ ขออภัยครับ จะมีที่แปลภาษาอังกฤษแนบเพิ่มไว้ด้านล่างครับ
- **EN:** Since my English is not strong, I originally wrote my answers in Thai. My apologies. An English translation is provided alongside each Thai section below.


## Part A - Bug tickets

### RES-101 · Search shows results for the wrong query

**Root cause**

- **TH:** เกิดจากเวลาที่พิมพ์ onChanged จะเรียก void onQueryChanged ทำให้ request ทุกครั้งที่มีการพิมพ์เกิดขึ้น และ จากโจทย์กรณีที่พิมพ์ 'sushi' ลบเหลือ 'su' แล้วเพิ่ม 'sushi' จะมีโอกาสที่ request ของ 'su' มาหลังจาก 'sushi' ทำให้ text ที่ search กับ list ข้อมูลไม่ตรงกัน
- **EN:** While typing, `onChanged` calls `void onQueryChanged`, so a request is fired on every keystroke. In the scenario from the ticket (type 'sushi', delete down to 'su', then type 'sushi' again), the response for 'su' may arrive after the response for 'sushi'. As a result, the search text and the displayed list no longer match.

**Fix**

- **TH:** เพิ่ม Debounce เวลาที่พิมพ์ เพื่อที่จะไม่ให้ request ทุกครั้งที่พิมพ์ กับ check text ที่เราส่งไป request กับ text ปัจจุบันตรงกันไหม ถ้าไม่ตรงจะไม่อัปเดท list ครับ
- **EN:** Add a debounce on typing so a request is not sent on every keystroke, and check whether the text that was sent with the request still matches the current text. If it does not match, the list is not updated.

**Edge cases:** -

### RES-102 · Crash after leaving My orders

**Root cause**

- **TH:** Timer ทำงานอยู่ แม้จะออกจากหน้า order แล้วทำให้ crash ครับ
- **EN:** The timer keeps running even after leaving the order page, which causes a crash.

**Fix**

- **TH:** ยกเลิก timer **_timer?.cancel();** เวลาที่ dispose (ออกจากหน้า order)
- **EN:** Cancel the timer with `_timer?.cancel();` in `dispose` (when leaving the order page).

**Edge cases:** -

### RES-103 · Requests pile up the longer you browse

**Root cause**

- **TH:** หน้า detail เพิ่ม ever() หรือ worker ที่คอยทำงานทุกครั้งที่ itemcount เปลี่ยนแล้วเรียกใช้ _recheckAvailability ทำให้เวลาที่เปิดหน้า detail จะเรียก worker เพิ่มเรื่อย ๆ เวลาที่กด addToCart ทำโชว์ข้อความบน console log เยอะตามจำนวนที่กดเข้าหน้า detail
- **EN:** The detail page registers an `ever()` worker that runs every time `itemCount` changes and calls `_recheckAvailability`. Because of this, every time the detail page is opened, another worker is added. When `addToCart` is pressed, the console log shows the message as many times as the number of times the detail page has been opened.

**Fix**

- **TH:** ยกเลิก worker **_cartWorker?.dispose();** เวลาที่ dispose (ออกจากหน้า detail)
- **EN:** Dispose of the worker with `_cartWorker?.dispose();` in `dispose` (when leaving the detail page).

**Edge cases:** -

### RES-104 · Duplicate deals in the home feed

### RES-105 · Home feed is janky and memory keeps climbing

### RES-106 · Wrong pickup times; "Pickup today" filter misses deals

**Root cause**

- **TH:** filter ทำงานถูกแล้วครับ ส่วนที่ผิดจะเป็นเรื่อง time zone ทำให้เวลาของ deal กับ เวลาเครื่องปัจจุบันไม่สัมพันธ์
- **EN:** The filter itself works correctly. The problem is the time zone: the deal's time and the device's current time are not comparable.

**Fix**

- **TH:** เพิ่ม .toLocal() ของ start กับ end ใน pickup_window_model ให้อ้างอิงเวลาท้องถิ่น (เวลาไทย UTC+7) ทำให้เวลา filter เวลาของ deal กับ เวลาเครื่องปัจจุบันสัมพันธ์กันแล้วครับ
- **EN:** Add `.toLocal()` to `start` and `end` in `pickup_window_model` so they refer to local time (Thailand time, UTC+7). The deal's time and the device's current time are now consistent when filtering.

**Edge cases:** -

### RES-107 · Deep link opens to a crash

**Root cause**

- **TH:** หน้า detail เบื้องต้นจะรับแค่ Get.arguments as DealModel ซึ่งทำให้เวลาที่มาในรูปแบบ deep links จะได้มาแค่ id ทำให้ data type มีปัญหาจนเกิด crash ครับ
- **EN:** The detail page originally only accepts `Get.arguments as DealModel`. When arriving via a deep link, only an `id` is received, so the data type is wrong and this causes a crash.

**Fix**

- **TH:** check Get.arguments มีค่าส่งมาไหม ถ้าไม่มีจะ check ค่าผ่านทาง parameter ถ้ามี id จะหา find deal กรณีที่ไม่เจอจะส่งกลับหน้า home ถ้าเจอก็ทำงานเหมือนกับ flow detail ปกติ
- **EN:** Check whether `Get.arguments` has a value. If not, read the value from the route parameter. If an `id` exists, look up the deal; if the deal is not found, navigate back to the home page, and if it is found, continue as in the normal detail flow.

**Edge cases:** -


## Part B — Features

### F-1 · Live flash-sale countdowns

**สิ่งที่ทำแล้ว / What has been done**

- **TH:** สร้าง CountdownService เพื่ออัปเดตเวลาปัจจุบันทุกวินาที โดยใช้ Timer ร่วมกันแทนการสร้าง Timer แยกสำหรับแต่ละการ์ด
- **EN:** Created `CountdownService`, which updates the current time every second using one shared Timer instead of creating a separate Timer for each card.

- **TH:** สร้าง CountdownText ซึ่งรับ deal.flashSaleEndsAt และใช้ ValueListenableBuilder เพื่อ rebuild เฉพาะส่วนข้อความ Countdown เมื่อเวลาปัจจุบันเปลี่ยน
- **EN:** Created `CountdownText`, which takes `deal.flashSaleEndsAt` and uses `ValueListenableBuilder` to rebuild only the countdown text when the current time changes.

**สิ่งที่ยังไม่ได้ทำ / What has not been done yet**

- **TH:** เวลา scroll ยังกระตุกอยู่ครับ
- **EN:** Scrolling is still janky.

- **TH:** เวลาที่ deal นั้นหมดเวลาจะลบ deal ที่อยู่ในตะกร้า
- **EN:** When a deal expires, the deal in the cart should be removed.

### F-2 · Impression tracking

### F-3 · Stock reservations with optimistic UI

## Part C — Written deliverables

### AI usage log

- **TH:** สรุปโจทย์ว่าต้องทำอะไรบ้างครับ รวมถึงช่วยดู bug บางส่วนด้วยครับ
- **EN:** Summarized what the assignment requires and got help reviewing some bugs.

  Link: [Claude conversation](https://claude.ai/share/7a73a30d-86fb-4e60-b57b-4f175403fa7b)

- **TH:** Claude ใช้งานครบตาม limit แล้ว เลยเปลี่ยนไปใช้ GPT แทนในเรื่อง Flash Deal expiry ครับ
- **EN:** I reached Claude's usage limit, so I switched to GPT for the Flash Deal expiry task.

  Link: [ChatGPT conversation](https://chatgpt.com/share/6ad1164f-4314-83ec-a472-41739bd55d28)

- **TH / EN:** Image and video recordings (screenshots and screen recordings).

  Link: [Google Drive folder](https://drive.google.com/drive/folders/1VnHk5OMMejUOuN-T9g6KD-pNIBNbgNN6?usp=sharing)

---

### Design questions

#### Q1: In this codebase, what is the difference between a `GetxController`'s lifecycle and a widget `State`'s lifecycle? Name one bug from Part A that exists because of confusion between the two.

- **TH:** state จะเกาะกับ widget ซึ่งทำให้กรณีที่ widget นั้นถูก dispose หรือปิดไปแล้ว state ก็จะทำลายตัวเองทันที ตัวอย่าง bug คือ RES-102 ที่ timer ยังทำงานหลังออกจากหน้า order และพยายามเรียก setState() หลัง widget ถูก dispose แล้ว ทำให้เกิด crash แก้โดยการ dispose() ตัว timer ของ widget ส่วน getx จะแยกออกจาก UI ทำหน้าที่จัดการ state กับ logic ผ่านตัว lifecycle ของเขาเองโดยผ่าน onInit(), onClose()
- **EN:** A widget `State` is tied to its widget: when the widget is disposed or closed, the `State` is destroyed immediately. An example bug is RES-102, where the timer kept running after leaving the order page and tried to call `setState()` after the widget had already been disposed, causing a crash. It was fixed by cancelling the timer in the widget's `dispose()`. A `GetxController`, on the other hand, is separate from the UI; it manages state and logic through its own lifecycle, via `onInit()` and `onClose()`.

#### Q2: When does wrapping a large subtree in a single `Obx` hurt you? How do you decide how tightly to scope reactivity?

- **TH:** กรณีที่ครอบไว้นอกสุด แล้วเวลาข้อมูลเปลี่ยนแปลง widget re-build แล้วกระพริบทำให้แอปพลิเคชันบางจุดดูแปลก ๆ ครับ ถ้าเป็นไปได้จะคลุมเฉพาะส่วนที่ต้องจำเป็นต้องอัปเดทบ่อย widget เท่านั้นครับ เพื่อให้ re-build แค่ส่วน ๆ นั้นครับ
- **EN:** When the `Obx` wraps the outermost part of the screen, every data change rebuilds the whole subtree, which can cause flickering and make some parts of the app look odd. Where possible, I wrap only the widgets that genuinely need to update often, so that only those parts rebuild.

#### Q3: How would you write an automated test that would have caught RES-106 before release? What (if anything) would you change in the code to make such a test possible?

- **TH:** test โดยการ mock ช่วงเวลาสำหรับทดสอบ pickup today filter นอกจากเวลาอาจจะเป็นเรื่อง time zone ที่ทำให้ .toLocal() อาจจะเปลี่ยนแปลง เพื่อทดสอบว่า deal ที่ได้จาก service สามารถ filter ได้ถูกต้องตามเวลานั้น ๆ
- **EN:** Write a test that mocks the time to exercise the "Pickup today" filter. Besides the time itself, the test could also cover time zones, since `.toLocal()` can change the result. The goal is to verify that deals obtained from the service are filtered correctly for that particular time.

---

### Time spent

**วันจันทร์ / Monday**

- **TH:** clone project กับ โยนโจทย์ให้ ai ครับ
- **EN:** Cloned the project and assignment to AI.

**วันพุธ / Wednesday**

- RES-101 [15:40-16:10] 30 นาที / 30 minutes
- RES-102 [16:10-16:40] 30 นาที / 30 minutes
- RES-106 [16:40-17:43] 1 ชั่วโมง 3 นาที / 1 hour 3 minutes

**วันพฤหัส / Thursday**

- RES-103 [12:30-12:55] 25 นาที / 25 minutes
- RES-107 [12:55-15:01] 2 ชั่วโมง 6 นาที / 2 hours 6 minutes
- F-1 [18:00-19:33] 1 ชั่วโมง 33 นาที / 1 hour 33 minutes
- F-1 [23:10-00:07] 57 นาที / 57 minutes

**Total / รวม**

- **TH:** coding 7 ชั่วโมง 4 นาที + solutions 1-2 ชั่วโมง = ~9 ชั่วโมง 4 นาที
- **EN:** coding 7 hours 4 minutes + writing solutions 1–2 hours = ~9 hours 4 minutes

### What you would do next with one more day

- **TH:** น่าจะทำต่อ F-1 ต่อครับ อุสาได้โจทย์ที่ผ่านกระบวนการคิดมาแล้วครับ ก็อยากทำเท่าที่ทำได้ครับ
- **EN:** I would continue working on F-1. Since the task I was given has clearly been thoughtfully designed, I want to do as much of it as I can.