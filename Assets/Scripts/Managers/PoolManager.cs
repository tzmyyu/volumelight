using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

namespace Managers
{
    /// <summary>
    /// 对象池
    /// </summary>
    /// <typeparam name="T"></typeparam>
 
    //池接口
    public interface IPool<T>
    {
        T Allocate();
        bool Recycle(T obj);
    }

    public interface IObjectFactory<T>
    {
        T Create();
    }

    //----------------------
    public abstract class Pool<T> : IPool<T>
    {
        #region ICountObserverable 
        public int CurCount
        {
            get { return mCacheStack.Count; }
        }
        #endregion
        protected Stack<T> mCacheStack = new Stack<T>();
        protected IObjectFactory<T> mFactory;
        protected int mMaxCount = 10;

        //分配池中的对象
        public virtual T Allocate()
        {
            return mCacheStack.Count == 0 
                ? mFactory.Create() 
                : mCacheStack.Pop();
        }

        public abstract bool Recycle(T obj);
    }
    
    public class CustomObjectFactory<T> : IObjectFactory<T>
    {
        public CustomObjectFactory(Func<T> factoryMethod)
        {
            mFactoryMethod = factoryMethod;
        }

        protected Func<T> mFactoryMethod;

        public T Create()
        {
            return mFactoryMethod();
        }
    }

    public class ObjectPool<T> : Pool<T>
    {
        readonly Action<T> mResetMethod;

        //建立新的对象池
        public ObjectPool(Func<T> factoryMethod, Action<T> resetMethod = null,int initCount = 0)
        {
            mFactory = new CustomObjectFactory<T>(factoryMethod);
            mResetMethod = resetMethod;

            for(var i= 0; i < initCount; i++)
            {
                mCacheStack.Push(mFactory.Create());
            }
        }

        //回收一个对象
        public override bool Recycle(T obj)
        {
            if(mResetMethod != null)
            {
                mResetMethod(obj);
            }

            mCacheStack.Push(obj);
            return true;
        }
    }
}
