package com.threerings.flashbang.pushbutton {
import com.threerings.flashbang.ObjectTask;
public interface Tasker
{

    /** Adds a named task to this GameObject. */
    function addNamedTask (name :String, task :ObjectTask, removeExistingTasks :Boolean =
        false) :void;

    /** Adds an unnamed task to this GameObject. */
    function addTask (task :ObjectTask) :void;

    /** Returns true if the GameObject has any tasks. */
    function hasTasks () :Boolean;

    /** Returns true if the GameObject has any tasks with the given name. */
    function hasTasksNamed (name :String) :Boolean;

    /** Removes all tasks from the GameObject. */
    function removeAllTasks () :void;

    /** Removes all tasks with the given name from the GameObject. */
    function removeNamedTasks (name :String) :void;
}
}