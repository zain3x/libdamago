package net.amago.util
{
public interface IObjectPool
{
    function getNewObject (clazz :Class) :*;
}
}