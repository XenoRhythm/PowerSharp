using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading.Tasks;

//todo
//etw patching
//amsi bypass

namespace powersharp
{
    internal class Program
    {
        static void Main(string[] args)
        {
            if (args.Length != 0)
            {
                if (args[0] == "-b64")
                {
                    if (!string.IsNullOrEmpty(args[1]))
                    {
                        var bytes = Convert.FromBase64String(args[1]);
                        var text = System.Text.Encoding.UTF8.GetString(bytes);
                        PSExec(text);
                    }
                }
                else
                {
                    PSExec(string.Join(" ", args));
                }
            }
            //Console.ReadKey();
            return;
        }

        static void PSExec(string cmd)
        {
            cmd = GetResource() + Environment.NewLine + cmd;

            PowerShell ps = PowerShell.Create();
            Collection<PSObject> results = ps.AddScript(cmd).Invoke();

            if (ps.HadErrors)
            {
                foreach (var error in ps.Streams.Error)
                {
                    Console.WriteLine("Error: " + error.ToString());
                }
            }
            else
            {
                foreach (PSObject result in results)
                {
                    Console.WriteLine(result.ToString());
                }
            }
        }
        static string GetResource()
        {
            string resName = null;
            if ((resName = System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceNames().FirstOrDefault()) != null)
            {
                return new StreamReader(System.Reflection.Assembly.GetExecutingAssembly().GetManifestResourceStream(resName)).ReadToEnd();
            }
            return null;
        }
    }
}


