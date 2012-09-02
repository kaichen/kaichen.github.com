---
layout: post
title: Learning tinyrb 1
---

<a href="http://code.macournoyer.com/tinyrb/">Tinyrb</a>，一个Ruby的实现，<a href="http://macournoyer.com">作者Marc-André Cournoyer</a>计划实现参照Lua和Potion实现来做出一个轻量级快速的Ruby实现，<a href="http://on-ruby.blogspot.com/2009/02/tinyrb-interview.html">这是一个对作者关于Tinyrb想法的采访</a>。目前还不能直接运行mspec，或者是我不知道怎么运行mspec。

其中用了一些外挂：
GC：Boehm-Demers-Weiser conservative garbage collector
语法解析（Lexical Parse）：peg/leg
命令行选项解析（Command-Line Option Parse）：Free Getopt
正则表达式解析（Regular Parse）：PCRE (Perl-compatible regular expression library)

Tinyrb到目前为止是个非常清晰简洁的实现，整个实现，VM+Ruby Library就200K多一点。编译运行非常简单，在Github上clone下来后make就行了。跑下Fib测试：

    ~/ws/tinyrb > time ruby bench/bm_app_fib.rb 
    real	0m10.866s
    user	0m9.393s
    sys	0m1.170s
    ~/ws/tinyrb > time ruby-1.9 bench/bm_app_fib.rb 
    real	0m1.827s
    user	0m1.423s
    sys	0m0.013s
    ~/ws/tinyrb > time jruby bench/bm_app_fib.rb 
    real	0m2.718s
    user	0m2.447s
    sys	0m0.097s
    ~/ws/tinyrb > time tinyrb bench/bm_app_fib.rb 
    real	0m1.884s
    user	0m1.680s
    sys	0m0.007s

运行环境：Archlinux，kernal26-2.26.29，Core T8100，2G Mem。或许Tinyrb目前实现还不完全，启动速度比其它的Ruby实现就快了不少。

现在来剖析一下源码，我们从Tinyrb解析器启动入手，整个解析器的启动是在vm/tr.c文件中定义的：

    /* file: vm/tr.c */
    int main (int argc, char *argv[]) {
      int opt;
      TrVM *vm = TrVM_new();
      while((opt = getopt(argc, argv, "e:vdh")) != -1) {
        switch(opt) {
          /* 参数解析 */
          ...
        }
      }
      /* 参数处理 */
      if (argc > 0) {
        TR_FAILSAFE(TrVM_load(vm, argv[argc-1]));
        return 0;
      }
      TrVM_destroy(vm);
      return usage();
    }

可以看到整个VM的启动由TrVM_new()开始

    /* file: vm/vm.c */
    /* GC初始化 */
    GC_INIT();
    /* [A]VM分配空间并初始化 */
    TrVM *vm = TR_ALLOC(TrVM);
    vm->symbols = kh_init(str);
    vm->globals = kh_init(OBJ);
    vm->consts = kh_init(OBJ);
    vm->debug = 0;
    /* [B]初始化几个核心类Method，Symbol，Class，Object，Module */
    TrMethod_init(vm);
    TrSymbol_init(vm);
    TrModule_init(vm);
    TrClass_init(vm);
    TrObject_preinit(vm);
    TrClass *symbolc = (TrClass*)TR_CORE_CLASS(Symbol);
    TrClass *modulec = (TrClass*)TR_CORE_CLASS(Module);
    TrClass *classc = (TrClass*)TR_CORE_CLASS(Class);
    TrClass *methodc = (TrClass*)TR_CORE_CLASS(Method);
    TrClass *objectc = (TrClass*)TR_CORE_CLASS(Object);
    /* [C]设置核心类的继承体系 */
    symbolc->super = modulec->super = methodc->super = (OBJ)objectc;
    classc->super = (OBJ)modulec;
    /* [D]设置核心类的MetaClass */
    symbolc->class = TrMetaClass_new(vm, objectc->class);
    modulec->class = TrMetaClass_new(vm, objectc->class);
    classc->class = TrMetaClass_new(vm, objectc->class);
    methodc->class = TrMetaClass_new(vm, objectc->class);
    objectc->class = TrMetaClass_new(vm, objectc->class);
    /* [E]确保所有在Object之前创建的的Symbol的类得到初始化 */
    TR_KH_EACH(vm->symbols, i, sym, {
      TR_COBJECT(sym)->class = (OBJ)symbolc;
    });
    /* [F]装入各种核心类 */
    ... 
    /* [G] */
    vm->self = TrObject_alloc(vm, 0);
    vm->cf = -1;
    /* [H]缓存几个常用的值 */
    vm->sADD = tr_intern("+");
    vm->sSUB = tr_intern("-");
    vm->sLT = tr_intern("<");
    vm->sNEG = tr_intern("@-");
    vm->sNOT = tr_intern("!");
    /* 装载Ruby Library（在lib/目录下的文件） */
    TR_FAILSAFE(TrVM_load(vm, "lib/boot.rb"));

在GC完成初始化之后，代码中[A]部分完成了维护整个Tinyrb运行环境的虚拟机对象的空间分配和初始化，VM是个宏：

    #define VM TrVM *vm

TrVM这个VM的结构包括了什么：

    /* file: vm/tr.h */
    typedef struct TrVM {
      khash_t(str) *symbols; /* 全局的符号表 */
      khash_t(OBJ) *globals; /* 全局对象 */
      khash_t(OBJ) *consts;  /* 全局常量 */
      OBJ classes[TR_T_MAX]; /* 虚拟机维护的核心类 */
      TrFrame *top_frame; /* 最顶层的栈幀（运行时栈的栈顶） */
      TrFrame *frame; /* 当前的栈幀 */
      int cf;   /* 栈幀的数量 count of frames */
      OBJ self; /* 根对象 */
      /* 调试和错误符号，还有一堆异常 */
      ...
      /* 几个缓存的对象 */
      OBJ sADD;
      OBJ sSUB;
      OBJ sLT;
      OBJ sNEG;
      OBJ sNOT;
    };

在前一块代码中设置的symbols，globals，consts就是保存运行时（Runtime）环境的各种信息，这几个变量都是Hash。接着下面的是Tinyrb的几个核心类列表，这是一个枚举值。然后是运行环境必不可少的栈帧，作用域调用就是靠这个维护的。栈幀由对象栈幀，栈顶，栈幀数这几个变量维护。还有一个虚拟机环境的根对象，这个对象就是在整个运行环境最外层作用域的对象，Ruby能做到不像Java那样写个什么都要包覆在一个对象中就是靠这个对象实现的，这个对象混入了Kernel模块，后面会看到每个栈帧（TrFrame）中都会有一个这样对象存在。最后是调试标记和异常信息，暂时略过。最后的几个常用的对象，可以看到在TrVM_new()中的[H]处进行初始化。

在VM的初始化中，中间的大段代码就是复杂完成Tinyrb的对象体系的构建，由Method开始初始化：

    /* file:vm/class.c */
    void TrMethod_init(VM) {
      OBJ c = TR_INIT_CORE_CLASS(Method, Object);
      tr_def(c, "name", TrMethod_name, 0);
      tr_def(c, "arity", TrMethod_arity, 0);
      tr_def(c, "dump", TrMethod_dump, 0);
    }

TR_INIT_CORE_CLASS这个宏会引发一连串复杂的调用：

    /* file:vm/tr.h */  
    #define TR_INIT_CORE_OBJECT(T) ({ \
      Tr##T *o = TR_ALLOC(Tr##T); \
      o->type  = TR_T_##T; \
      o->class = vm->classes[TR_T_##T]; \
      o->ivars = kh_init(OBJ); \
      o; \
    })
    #define TR_CORE_CLASS(T)     vm->classes[TR_T_##T]
    #define TR_INIT_CORE_CLASS(T,S) \
      TR_CORE_CLASS(T) = TrObject_const_set(vm, vm->self, tr_intern(#T), \
                                       TrClass_new(vm, tr_intern(#T), TR_CORE_CLASS(S)))
    /* vm/class.c */        
    OBJ TrClass_new(VM, OBJ name, OBJ super) {
      TrClass *c = TR_INIT_CORE_OBJECT(Class);
      TR_INIT_MODULE(c);
      /* if VM is booting, those might not be set */
      if (super && TR_CCLASS(super)->class) c->class = TrMetaClass_new(vm, TR_CCLASS(super)->class);
      c->super = super;
      return (OBJ)c;
    }
    #define TR_INIT_MODULE(M) \
      (M)->name = name; \
      (M)->methods = kh_init(OBJ); \
      (M)->meta = 0

TR_INIT_CORE_CLASS(Method, Object);展开如下

    TrClass *obj = TR_ALLOC(TrClass);
    obj->type  = TR_T_Class;
    obj->class = vm->classes[TR_T_Class];/* 实际上这句将其赋值为0，因为VM内部还没有创建Class类型 */
    obj->ivars = kh_init(OBJ); 
    obj->name = tr_intern(Method);
    obj->methods = kh_init(OBJ);
    obj->meta = 0;
    obj->super = vm->classes[TR_T_Object]; /* 实际上这句将其赋值为0，因为VM内部还没有创建Object类型 */
    OBJ const_class = TrObject_const_set(vm, vm->self, tr_intern(Method), (OBJ)obj);
    vm->classes[TR_T_Method]=const_class;

这样很清楚看到Method这个类初始化的过程，首先分配一个类（TrClass）的内存空间，接着设置所有的属性，之后把这个Method类设置到VM的常量列表，最后将这个Method类的对象地址保存到虚拟机的类型列表（Classes List）。注意这里其实Method类的class和super都是为0的。

顺便提一下，Tinyrb内部的对象类型（Object type）就是这个枚举值。

    /* file: vm/tr.h */
    typedef enum {
      /*  0 */ TR_T_Object, TR_T_Module, TR_T_Class, TR_T_Method, TR_T_Binding,
      /*  5 */ TR_T_Symbol, TR_T_String, TR_T_Fixnum, TR_T_Range, TR_T_Regexp,
      /* 10 */ TR_T_NilClass, TR_T_TrueClass, TR_T_FalseClass,
      /* 12 */ TR_T_Array, TR_T_Hash,
      /* 14 */ TR_T_Node,
      TR_T_MAX /* keep last */
    } TR_T;

当Method的属性设置完成之后接着就开始为其添加方法name()，arity(), dump()。添加方法是通过之前已经设置好的Method类，实例化三个Method Object，并把这三个对象添加到Method类的方法列表中，下面是tr_def(c, "name", TrMethod_name, 0) 的展开：

    TrMethod *method = TR_INIT_CORE_OBJECT(Method); /* 初始化一个Method对象并返回 */
    method->func = TrMethod_name;
    method->data = TR_NIL;
    method->arity = 0;
    TrClass *m =  (TrClass*)E(vm->classes[TR_T_Method])
    TR_KH_SET(m->methods, name, method);
    method->name = name;

接着其它几个类型也类似的过程进行初始化:Symbol，Module，Class和Object。

到此为止VM的Const List已经有了这几个类Method，Symbol，Module，Class，Object，并且它们的第一个实例也已经保存到Classes List中。接着这些类的继承体系和剩下的核心类怎样初始化呢？请听下回分解。
