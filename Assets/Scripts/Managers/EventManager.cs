using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace Managers
{
    public static class EventManager
    {
        /// <summary>
        /// 有参无返回类型方法字典
        /// </summary>
        public static Dictionary<string, Action<object>> DataEventDic = new Dictionary<string, Action<object>>();

        public static Dictionary<string, Action> EventDic = new Dictionary<string, Action>();



        /// <summary>
        /// 添加事件绑定
        /// </summary>
        /// <param name="data">绑定的数据类</param>
        /// <param name="name">绑定的数据名</param>
        /// <param name="action">回调方法</param>
        public static void AddEvent(string name, Action<object> action)
        {
            if (!DataEventDic.ContainsKey(name))
            {
                DataEventDic.Add(name, null);
            }
            DataEventDic[name] +=  action;
        }
        public static void AddEvent(string name, Action action)
        {
            if (!EventDic.ContainsKey(name))
            {
                EventDic.Add(name, null);
            }
            EventDic[name] += action;
        }
        /// <summary>
        /// 删除全部事件
        /// </summary>
        /// <param name="name">绑定的数据名</param>
        public static void DeleteEventAll( string name)
        {
            if (DataEventDic.ContainsKey(name))
            {
                DataEventDic.Remove(name);
            }
            else if(EventDic.ContainsKey(name))
            {
                EventDic.Remove(name);
            }
            else
            {
                Debug.LogWarning("找不到要删除的事件");
            }
        }
        /// <summary>
        /// 删除事件的一个方法
        /// </summary>
        /// <param name="data">绑定的数据类</param>
        /// <param name="name">绑定的数据名</param>
        /// <param name="action">绑定的数据方法</param>
        public static void DeleteEvent(string name,Action<object> action)
        {
            if (DataEventDic.ContainsKey(name))
            {
                DataEventDic[name] -= action ;
            }

        }
        public static void DeleteEvent(string name, Action action)
        {
            if (EventDic.ContainsKey(name))
            {
                EventDic[name] -= action;
            }

        }
        //=============================================================================
        /// <summary>
        /// 调用事件
        /// </summary>
        /// <param name="send">属性值</param>
        /// <param name="key">命名空间类名属性名</param>
        internal static void InvokeEvent(object send, string key)
        {
            Action<object> hpEvent;
            if (DataEventDic.TryGetValue(key, out hpEvent))
            {
                if (hpEvent != null)
                {
                    hpEvent(send);
                }
            }
            else
            {
                Debug.LogWarning(key + "is null");
            }
        }
        internal static void InvokeEvent(string key)
        {
            Action hpEvent;
            if (EventDic.TryGetValue(key, out hpEvent))
            {
                if (hpEvent != null)
                {
                    hpEvent();
                }
            }
            else
            {
                Debug.LogWarning(key + "is null");
            }
        }
        /// <summary>
        /// 获得Key的名称
        /// </summary>
        /// <param name="obj">类名</param>
        /// <param name="name">属性名</param>
        /// <returns></returns>
        public static string GetKeyName(object obj, string name)
        {
            string str;
            Type T = obj.GetType();
            str = T.Namespace;
            str += T.Name;
            MethodInfo m = T.GetMethod(name);
            if (m != null)
            {
                str += m.Name;
                return str;
            }
            PropertyInfo p = T.GetProperty(name);
            if (p != null)
            {
                str += p.Name;
                return str;
            }
            FieldInfo f = T.GetField(name);
            if (f != null)
            {
                str += p.Name;
                return str;
            }

            Debug.LogError("dataEventDic  Key=null");
            return null;

        }
    }
}
