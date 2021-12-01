using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Configuration;
using dotnet_demo_app.Models;

namespace dotnet_demo_app.Controllers
{
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private IConfiguration config;

        public HomeController(ILogger<HomeController> logger, IConfiguration config)
        {
            _logger = logger;
            this.config = config;
        }

        public IActionResult Index()
        {
            ViewData["Title"] = config.GetValue<string>("AppName");
            ViewData["Company"] = config.GetValue<string>("COMPANY");
            return View();
        }
    }
}
