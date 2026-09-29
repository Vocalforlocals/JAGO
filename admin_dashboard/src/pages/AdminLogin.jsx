import React, { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { ShieldCheck, Lock, Mail, ArrowRight, CheckCircle2 } from 'lucide-react';
import { adminApi } from '../services/adminApi';

export default function AdminLogin({ onLoginSuccess }) {
  const navigate = useNavigate();
  const [email, setEmail] = useState('officer@mota.gov.in');
  const [password, setPassword] = useState('demo123');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError('');

    try {
      const res = await adminApi.login(email, password);
      localStorage.setItem('jago_officer_token', res.access_token);
      localStorage.setItem('jago_officer_user', JSON.stringify(res));
      if (onLoginSuccess) onLoginSuccess(res);
      navigate('/admin/dashboard');
    } catch (err) {
      setError(err.message || 'Login failed. Please check credentials.');
    } finally {
      setLoading(false);
    }
  };

  const handleDemoFill = () => {
    setEmail('officer@mota.gov.in');
    setPassword('demo123');
  };

  return (
    <div className="min-h-screen bg-slate-900 flex flex-col justify-center py-12 sm:px-6 lg:px-8 relative overflow-hidden">
      {/* Background graphic elements */}
      <div className="absolute top-0 left-1/4 w-96 h-96 bg-emerald-500/10 rounded-full blur-3xl pointer-events-none"></div>
      <div className="absolute bottom-0 right-1/4 w-96 h-96 bg-blue-500/10 rounded-full blur-3xl pointer-events-none"></div>

      <div className="sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        <div className="flex justify-center">
          <div className="h-16 w-16 rounded-2xl bg-gradient-to-tr from-emerald-600 to-teal-500 text-white flex items-center justify-center text-3xl shadow-lg border border-emerald-400/30">
            🏛️
          </div>
        </div>
        <h2 className="mt-4 text-center text-2xl font-extrabold text-white tracking-tight">
          Officer Review Portal
        </h2>
        <p className="mt-1 text-center text-sm text-slate-400">
          National Unified Scholarship Platform • Central Verification
        </p>
        <p className="text-center text-xs text-emerald-400 font-semibold mt-1">
          JAGO National Verification & Discrepancy Resolution Engine
        </p>
      </div>

      <div className="mt-8 sm:mx-auto sm:w-full sm:max-w-md relative z-10">
        <div className="bg-slate-800/90 py-8 px-6 shadow-xl rounded-2xl sm:px-10 border border-slate-700/80 backdrop-blur-sm">
          {error && (
            <div className="mb-5 bg-rose-500/10 border border-rose-500/30 text-rose-300 text-xs p-3 rounded-lg">
              {error}
            </div>
          )}

          <form className="space-y-5" onSubmit={handleSubmit}>
            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Officer Email / ID
              </label>
              <div className="mt-1.5 relative rounded-lg shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <Mail className="h-4 w-4" />
                </div>
                <input
                  type="email"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                  className="block w-full pl-10 pr-3 py-2.5 bg-slate-900 border border-slate-700 rounded-lg text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                  placeholder="officer@mota.gov.in"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider">
                Password
              </label>
              <div className="mt-1.5 relative rounded-lg shadow-sm">
                <div className="absolute inset-y-0 left-0 pl-3 flex items-center pointer-events-none text-slate-400">
                  <Lock className="h-4 w-4" />
                </div>
                <input
                  type="password"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                  className="block w-full pl-10 pr-3 py-2.5 bg-slate-900 border border-slate-700 rounded-lg text-sm text-white placeholder-slate-500 focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-emerald-500"
                  placeholder="••••••••"
                />
              </div>
            </div>

            <div className="bg-slate-900/60 p-3 rounded-lg border border-slate-700/60 flex items-center justify-between">
              <div>
                <p className="text-[11px] text-slate-400 font-medium">Demo Credentials:</p>
                <p className="text-xs font-mono text-emerald-400">officer@mota.gov.in / demo123</p>
              </div>
              <button
                type="button"
                onClick={handleDemoFill}
                className="text-xs text-slate-300 hover:text-white underline font-medium"
              >
                Auto-fill
              </button>
            </div>

            <div>
              <button
                type="submit"
                disabled={loading}
                className="w-full flex justify-center items-center py-2.5 px-4 border border-transparent rounded-lg shadow-md text-sm font-semibold text-white bg-emerald-600 hover:bg-emerald-500 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-emerald-500 transition duration-150 disabled:opacity-50"
              >
                {loading ? 'Authenticating...' : 'Sign in as Verification Officer'}
                {!loading && <ArrowRight className="ml-2 h-4 w-4" />}
              </button>
            </div>
          </form>

          <div className="mt-6 border-t border-slate-700/80 pt-4 text-center">
            <p className="text-xs text-slate-400">
              Are you a student?{' '}
              <span className="text-emerald-400 font-semibold cursor-pointer">
                Access Mobile Student App via Flutter
              </span>
            </p>
          </div>
        </div>

        <p className="mt-4 text-center text-xs text-slate-500">
          Demo / Mock Security Environment • Protected National Scholarship Infrastructure
        </p>
      </div>
    </div>
  );
}
