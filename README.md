# StepRecorder
##  StepRecorder 源码导读教程

鉴于 **Swift** 的开源以及简单易学的语法，它称霸 iOS 开发的日子一定会到来。所以最近就写了个小项目，包括了 iOS8 的 **HealthKit**,练练手感受一下这门语言。项目涉及的东西不太多，但是还是能让你简单的看到一些 Swift 的基本使用。
  
 
###   项目设置

在创建这个项目的时候选择:
Tabbed based Application
接下来就只要在项目的语言中选择 Swift
  
###   Swift 基础

打开项目后，你会发现并没有看到.h头文件。这也是 Swift 带来的福利之一，一个.Swift文件就够了，你能在其余的 .swift 文件中随意引用你写过的类。稍后我在说一下如何让你的方法私有如何是公开方法之类。接下来删除一些多余文件（`FirstViewController.swift` ,`SecondViewController.swift` ...）。打开 storyboard 看到之中有一个 Tab Bar Controller,这就是程序的根视图控制器，右键控制器就能看到它绑定的其它视图控制器。

我比较喜欢用代码的方式初始化 UI，所以我新建了一个`HHRootViewController` 类来绑定根视图控制器。Swift 中创建一个对象的方法是 **var(let) variablename :  classname**, 一般let是用来创建常量，var创建变量。`tab_addWorkout = _myTab.items![0] as! UITabBarItem`  来获得添加项的变量实例，没有接触过Swift的话，**！**和 **as** 应该是全新的东西，由于 Swift 的安全性比较高 `_myTab[0]` 可能是不存在的也就是 nil,这样写 Swift 会认为是不安全的。**!** 会成为隐式强拆包类型，这表示这个类型永远不会出现 nil 的情况，但一旦出来，在调用时就会崩溃。既然我们已经知道 UITabBarItem 的个数所以这么写是没问题的。**as** 就像表面的意思一样作为一个 UITabBarItem ，这种语法算是一种强制转化，因为 .items[index] 返回的是一个 anyObject 可以是任何类型。有时候也会遇到 ? 这个符号，因为使用 **var** 定义变量的时候 Swift 并不会默认赋值，这个变量没有得到内存，编译器就不会通过加上 ? 就声明这个变量为optional类型。从这些方面来看 Swift 是一个语法比较严格的语言。

这里面也涉及到多语言的本地化问题，大部分过程都和 Objective-C 的过程基本相似，`NSBundle.mainBundle().localizedStringForKey(keyString, value: keyString, table: nil)-> String` 这个函数将会返回本地化过后的 string 。像这种很长又很常用的方法和变量可以提取出一个全局类写一个静态函数：
	
```
class HHGlobalMethod: NSObject {
    static var kScreenSize: CGSize = UIScreen.mainScreen().bounds.size
    static func LocalizedString(keyString: String) ->String?
    {
        return NSBundle.mainBundle().localizedStringForKey(keyString, value: keyString, table: nil)
    }
}
```

这就简单定义了一个上述的类，通过 **static** 来声明类方法，变量。如果想调用本地化方法就可以直接 `HHGlobalMethod.LocalizedString(string)` 。其实 Swift 的很多关键字都很像 c++ 除了 **static** 还有 **private** 这样你就可以定义一个私有的变量，和 MFC jave 类似当你想重写一些类方法的时候加上 **override** 关键字。

好吧感觉不能写得太细致，不然怎么也写不完。下面简单讲讲 **HealthKit** 的实现。

### HealthKit相关

想在iOS的健康app中添加数据或者读取信息首先你得有一个开发者账号，并且打开 HealthKit Capabilities

接着我就写了一个 `HealthManager` 类用来处理所以项目中涉及到和 **HealthKit** 打交道的东西。`let healthKitStore:HKHealthStore = HKHealthStore()` 这一个变量是最重要的一个变量，所以获取健康信息和读取信息都是从这个变量调用方法获得。对于这种健康隐私信息，苹果都会给用户选择 app 权限的选项，所以第一步的做法是申请权限。

#### 申请权限：

```
func authorizeHealthKit(completion: ((success:Bool, error:NSError!) -> Void)!)
    {
        //1
        let healthKitTypesToWrite: Set = [
            HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount),
        ]
         
       //2
        if !HKHealthStore.isHealthDataAvailable() {
            let error = NSError(domain: "com.hihex.healthkit", code: 2, userInfo: [NSLocalizedDescriptionKey:"HealthKit is not available in this Device"])
            if completion != nil {
                completion(success:false, error:error)
            }
            return;
        }
     //3
        healthKitStore.requestAuthorizationToShareTypes(healthKitTypesToWrite, readTypes: nil) { (success, error) -> Void in
            
            if completion != nil {
                completion(success:success,error:error)
            }
        }
    }
   
```

1. 写上需要申请的权限集合，因为 app 内读取自己写入的数据不需要读取的权限所以我就没有申请读取的权限。

2. 检查设备是否能获取到健康的信息，因为有些机型如 iPad 等并不能支持 **HealthKit** 。

3. 申请权限，因为传入的是一个块你可以根据处理的结果进行 UI 上的交互。 

事实上 **HealthKit** 的内容是极其丰富的，光是活动的类型就支持70多种，可以在 `HKWorkoutActivityType` 里查看。这个简单的项目就没有写这么多了，有兴趣可以自己看看。
  
#### 保存运动样本：

```
func saveStepsSample( steps: Double, endDate: NSDate , duration :Int, completion: ( (Bool, NSError!) -> Void)!) {
        //1
        let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let stepsQuantity = HKQuantity(unit: HKUnit.countUnit(), doubleValue: steps)
        let startDate = endDate.dateByAddingTimeInterval(0 - 60 * Double(duration))
       //2
        let stepsSample = HKQuantitySample(type: HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount), quantity: stepsQuantity, startDate: startDate, endDate: endDate)
        //3
        self.healthKitStore.saveObject(stepsSample, withCompletion: { (success, error) -> Void in
            completion(success,error)
        })
    }
```

在一个运动的样本中，先把各项要使用的数据初始化：运动样本的类型，计算的单位，开始以及结束时间。
生成运动的样本。
在 **HealthKit** 中保存样本。

#### 读取运动样本：

```
func readStepsWorksout(limit :Int,completion: (([AnyObject]!, NSError!) -> Void)!) {
        //1
        let sampleType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierStepCount)
        let sortDescriptor = NSSortDescriptor(key:HKSampleSortIdentifierStartDate, ascending: false)
        let predicate = HKQuery.predicateForObjectsFromSource(HKSource.defaultSource())
       //2
        let sampleQuery = HKSampleQuery(sampleType: sampleType, predicate: predicate, limit: limit, sortDescriptors: [sortDescriptor])
            { (sampleQuery, results, error ) -> Void in
                if let queryError = error {
                    println( "There was an error while reading the samples: \(queryError.localizedDescription)")
                }
                completion(results,error)
        }
        healthKitStore.executeQuery(sampleQuery)
    }
```
    
1. 为需要查询的条件赋值：样本类型，排序要求，数据源筛选。

2. 使用 **HealthKit** 的方法进行查询，返回的结果在 result 中，返回的是样本的数组。

基本上 **HealthKit** 这方面需要打交道的工作都完成了。

### 其它UI

   接下来主要的工作就是UI了，其实大部分的东西和之前的 objective-C 并没有什么太大的区别，除了语法的格式看起来不太一样，我相信看下源码就都OK了。稍微值得看的一些地方：
	
1. 在实现运动时长设定的时候自定义的一个 UIPickerView。（ `HHAddStepsViewController.swift` ）

2. 项目中对 NSDate 的处理以及格式化文本。（ `HHAddStepsViewController.swift` ）

3. tableview 设置自己想贴上 FirstResponderView。（ `HHAddStepsViewController.swift` ）

4. 加载本地网页和拉取更新服务器上的网页。（ `HHRootViewController.swift` & `HHAboutViewController.swift` ）

5. 拿到数据样本之后在 tableview 中的显示。（ `HHHistoryViewController.Swift` ）

### Swift 支持 Objective-C 代码
   
项目的最后加上了谷歌分析的代码，那我就提一下如何在 Swift 中使用 Objective-C 的代码，相信也是比较实用的东西。首先新建一个头文件命名的时候按照如下格式 ProjectName-Bridging-Header.h，在头文件中 #import 所以你需要的 Objective-C 头文件。然后选中 Target 选择 build settings，搜索 Swift 找到 objective -c bridging-header 然后填上你写的头文件的路径。最后你就可以用 Swift 文件中调用 Objective-C 的类了。



**以上希望能帮助一下同学们学习和了解 Swift 还有 HealthKit。**








